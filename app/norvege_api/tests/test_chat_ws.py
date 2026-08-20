import jwt
import json
from app.core.config import settings
from unittest.mock import patch
from fastapi import HTTPException

def test_websocket_chat_authentication_failure(client):
    # On teste que la socket se coupe si le format JSON est mauvais ou le token invalide
    with client.websocket_connect("/ws/chat") as websocket:
        websocket.send_text("Ceci n'est pas un JSON valide")
        
        # Le backend doit renvoyer un message d'erreur puis couper
        response = websocket.receive_text()
        assert "Erreur" in response

def test_websocket_chat_success_flow(client, mock_supabase):
    # Génération d'un token valide
    token = jwt.encode({"sub": "fake-uuid"}, settings.SUPABASE_JWT_SECRET, algorithm="HS256")
    
    # Mock du service d'historique pour éviter l'appel base de données
    with patch('app.routers.chat_ws.history_service.get_recent_messages') as mock_history, \
         patch('app.routers.chat_ws.ai_tutor.generate_response') as mock_ai, \
         patch('app.routers.chat_ws.history_service.save_messages') as mock_save:
        
        # Faux historique vide
        mock_history.return_value = []
        # Fausse réponse de l'agent
        mock_ai.return_value = '{"reply": "Tusen takk", "ui_action": {"type": "input"}}'

        with client.websocket_connect("/ws/chat") as websocket:
            # 1. Envoi du payload d'authentification
            auth_payload = json.dumps({"token": token})
            websocket.send_text(auth_payload)
            
            # 2. Réception du message de bienvenue
            welcome = websocket.receive_json()
            assert welcome["status"] == "connected"
            
            # 3. Envoi d'un message utilisateur en norvégien
            websocket.send_text("Hvordan går det?")
            
            # 4. Réception de la réponse de l'IA (mocker précédemment)
            ai_reply = websocket.receive_text()
            assert "Tusen takk" in ai_reply
            
def test_websocket_chat_image_success(client, mock_supabase):
    """Teste le flux où le Tuteur demande une image et l'Agent Ressources réussit."""
    token = jwt.encode({"sub": "fake-uuid"}, settings.SUPABASE_JWT_SECRET, algorithm="HS256")
    
    with patch('app.routers.chat_ws.history_service.get_recent_messages') as mock_history, \
         patch('app.routers.chat_ws.ai_tutor.generate_response') as mock_ai, \
         patch('app.routers.chat_ws.resource_agent.generate_image') as mock_resource:
        
        mock_history.return_value = []
        
        # Le Tuteur déclenche une action visuelle
        mock_ai.return_value = json.dumps({
            "reply": "Décris cette image !",
            "ui_action": {"type": "image_description", "image_prompt": "A beautiful fjord"}
        })
        
        # L'Agent Ressources réussit sa génération
        mock_resource.return_value = "data:image/jpeg;base64,ZmFrZV9pbWFnZV9kYXRh"

        with client.websocket_connect("/ws/chat") as websocket:
            # Auth
            websocket.send_text(json.dumps({"token": token}))
            websocket.receive_json() # Ignore le message de bienvenue
            
            # Action de l'utilisateur
            websocket.send_text("Je suis prêt.")
            
            # Réception du JSON final
            final_response = websocket.receive_json()
            
            # Vérifications
            assert mock_resource.called
            assert final_response["ui_action"]["type"] == "image_description"
            assert final_response["image_data"] == "data:image/jpeg;base64,ZmFrZV9pbWFnZV9kYXRh"
            assert "Décris cette image" in final_response["reply"]


def test_websocket_chat_image_fallback(client, mock_supabase):
    """Teste la résilience de la WebSocket si l'API d'image plante."""
    token = jwt.encode({"sub": "fake-uuid"}, settings.SUPABASE_JWT_SECRET, algorithm="HS256")
    
    with patch('app.routers.chat_ws.history_service.get_recent_messages') as mock_history, \
         patch('app.routers.chat_ws.ai_tutor.generate_response') as mock_ai, \
         patch('app.routers.chat_ws.resource_agent.generate_image') as mock_resource:
        
        mock_history.return_value = []
        
        # Le Tuteur demande une image
        mock_ai.return_value = json.dumps({
            "reply": "Que vois-tu ?",
            "ui_action": {"type": "image_description", "image_prompt": "A beautiful fjord"}
        })
        
        # L'Agent Ressources PLANTE (timeout, erreur 500, etc.)
        mock_resource.side_effect = Exception("Hugging Face API Down")

        with client.websocket_connect("/ws/chat") as websocket:
            # Auth
            websocket.send_text(json.dumps({"token": token}))
            websocket.receive_json() # Ignore le message de bienvenue
            
            # Action de l'utilisateur
            websocket.send_text("Je suis prêt.")
            
            # Réception du JSON final intercepté et corrigé
            final_response = websocket.receive_json()
            
            # Vérifications de la sécurité anti-crash
            assert mock_resource.called
            # Le type d'action DOIT avoir été transformé en "input" simple
            assert final_response["ui_action"]["type"] == "input"
            # L'image ne doit pas être présente
            assert "image_data" not in final_response
            # Le message d'excuse doit avoir été ajouté
            assert "L'image n'a pas pu être chargée" in final_response["reply"]