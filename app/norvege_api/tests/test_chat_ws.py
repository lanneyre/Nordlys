import jwt
import json
from app.core.config import settings
from unittest.mock import patch

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