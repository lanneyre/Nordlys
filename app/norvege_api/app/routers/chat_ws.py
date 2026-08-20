import json
import asyncio
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from pydantic import ValidationError

from app.core.websocket_manager import manager
from app.core.security import verify_supabase_token
from app.schemas.chat_ws import WebSocketAuthPayload
from app.services import history_service, ai_tutor, evaluator_agent, resource_agent

from app.core.config import settings

router = APIRouter()

@router.websocket("/ws/chat")
async def websocket_chat_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    
    try:
        raw_data = await websocket.receive_text()
        
        try:
            data = json.loads(raw_data)
            auth_payload = WebSocketAuthPayload(**data)
        except (json.JSONDecodeError, ValidationError):
            await manager.send_personal_message("Erreur : Format d'authentification invalide.", websocket)
            manager.disconnect(websocket)
            return

        try:
            user_data = verify_supabase_token(auth_payload.token)
            # On récupère l'identifiant unique de l'utilisateur depuis le JWT
            user_id = user_data.get("sub") 
        except Exception as e:
            # 1. AJOUTE CETTE LIGNE POUR VOIR LE VRAI PROBLÈME DANS LE TERMINAL PYTHON 👇
            print(f"🔥 VRAIE ERREUR JWT : {repr(e)}") 
            
            # 2. Modifie temporairement le message renvoyé à Flutter pour l'inclure
            await websocket.send_text(f"Erreur : Token invalide. Détail : {str(e)}")
            await websocket.close()
            # await manager.send_personal_message("Erreur : Token invalide ou expiré.", websocket)
            # manager.disconnect(websocket)
            return

        # --- HYDRATATION DU CONTEXTE ---
        # L'historique est désormais lié au user_id
        chat_context = await history_service.get_recent_messages(user_id)
        
        await manager.send_personal_message('{"status": "connected", "message": "Velkommen! L\'historique est chargé."}', websocket)

        while True:
            user_text = await websocket.receive_text()
            
            # --- ÉVALUATION DE LA PROGRESSION (NOUVEAU) ---
            # On vérifie en tâche de fond si le message permet de valider l'étape
            asyncio.create_task(
                evaluator_agent.evaluate_step_progression(user_id, user_text)
            )
            
            # On ajoute le message de l'apprenant au contexte mémoire
            chat_context.append({"role": "user", "content": user_text})
            
            # --- APPEL À GEMINI ---
            # get_recent_messages() doit renvoyer la liste pour l'injecter ici
            agent_json_string = await ai_tutor.generate_response(user_id=user_id, user_message=user_text, chat_context=chat_context, show_hud=False)
            
            # On parse le JSON garanti par Gemini pour l'ajouter proprement à l'historique
            agent_data = json.loads(agent_json_string)
            agent_text = agent_data.get("reply", "")
            ui_action = agent_data.get("ui_action", {})
            
            # 2. APPEL À L'AGENT RESSOURCES (Interception)
            if ui_action.get("type") == "image_description":
                # On récupère le prompt généré par Gemini ou on met un fallback
                image_prompt = ui_action.get("image_prompt", "A beautiful Norwegian landscape")
                
                try:
                    # Génération de l'image en Base64
                    base64_image = await resource_agent.generate_image(image_prompt)
                    
                    # Injection de l'image dans la structure de données
                    agent_data["image_data"] = base64_image
                    
                    # On re-sérialise le JSON avec la nouvelle donnée
                    agent_json_string = json.dumps(agent_data)
                    
                except Exception as e:
                    # Sécurité : Si Hugging Face échoue (timeout, etc.), on modifie l'UI pour ne pas faire planter Flutter
                    agent_data["ui_action"]["type"] = "input"
                    agent_data["reply"] += "\n\n*(L'image n'a pas pu être chargée, mais décris-moi un paysage norvégien !)*"
                    agent_json_string = json.dumps(agent_data)
            
            # On ajoute la réponse au contexte en mémoire
            chat_context.append({"role": "agent", "content": agent_text})
            
            # On renvoie la structure complète (avec le flag is_correction) à Flutter
            await manager.send_personal_message(agent_json_string, websocket)

            # --- SAUVEGARDE ASYNCHRONE ---
            asyncio.create_task(
                history_service.save_messages(user_id, user_text, agent_text)
            )
            
            # Le +1 permet de compter le message utilisateur entrant actuel
            total_messages = len(chat_context)
            if total_messages > 0 and total_messages % settings.EVALUATION_COMPTEUR == 0:
                # Lance l'évaluation en arrière-plan sans bloquer la WebSocket
                asyncio.create_task(
                    ai_tutor.auto_evaluate_level(user_id, chat_context)
                )

    except WebSocketDisconnect:
        manager.disconnect(websocket)