import json
import asyncio
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from pydantic import ValidationError

from app.core.websocket_manager import manager
from app.core.security import verify_supabase_token
from app.schemas.chat_ws import WebSocketAuthPayload
from app.services import history_service
from app.services import ai_tutor

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
            await manager.send_personal_message("Erreur : Token invalide ou expiré.", websocket)
            manager.disconnect(websocket)
            return

        # --- HYDRATATION DU CONTEXTE ---
        # L'historique est désormais lié au user_id
        chat_context = await history_service.get_recent_messages(user_id)
        
        await manager.send_personal_message('{"status": "connected", "message": "Velkommen! L\'historique est chargé."}', websocket)

        while True:
            user_text = await websocket.receive_text()
            # On ajoute le message de l'apprenant au contexte mémoire
            chat_context.append({"role": "user", "content": user_text})
            
            # --- APPEL À GEMINI ---
            # get_recent_messages() doit renvoyer la liste pour l'injecter ici
            agent_json_string = await ai_tutor.generate_response(chat_context)
            
            # On parse le JSON garanti par Gemini pour l'ajouter proprement à l'historique
            agent_data = json.loads(agent_json_string)
            agent_text = agent_data["content"]
            
            # On ajoute la réponse au contexte en mémoire
            chat_context.append({"role": "agent", "content": agent_text})
            
            # On renvoie la structure complète (avec le flag is_correction) à Flutter
            await websocket.send_text(agent_json_string)

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