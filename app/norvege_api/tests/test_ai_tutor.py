import pytest
from unittest.mock import patch, MagicMock
from app.services.ai_tutor import generate_response

@pytest.mark.asyncio
@patch('app.services.ai_tutor.client.models.generate_content')
@patch('app.services.ai_tutor.supabase')
async def test_generate_response(mock_supabase, mock_generate):
    # 1. Configurer le mock Supabase pour le profil
    mock_profile_execute = mock_supabase.table().select().eq().single().execute
    mock_profile_execute.return_value.data = {
        "username": "TestUser",
        "current_level": "A2",
        "target_level": "B2",
        "learning_mode": "Sérieux 📚"
    }
    
    # 2. Configurer le mock Supabase pour le scénario actif
    mock_scenario_execute = mock_supabase.table().select().eq().execute
    mock_scenario_execute.return_value.data = [] # Pas de scénario actif pour ce test

    # 3. Configurer le faux retour de Gemini
    mock_generate.return_value.text = '{"reply": "Hei [[TestUser]]!", "ui_action": {"type": "input"}}'

    # 4. Exécuter la fonction
    chat_context = [{"role": "user", "content": "Hei!"}]
    result = await generate_response(
        user_id="fake-uuid", 
        user_message="Hei!", 
        chat_context=chat_context, 
        show_hud=False
    )

    # 5. Vérifier que la réponse correspond au mock et que l'API a été appelée
    assert "Hei [[TestUser]]!" in result
    assert mock_generate.called