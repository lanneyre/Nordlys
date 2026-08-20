import pytest
from unittest.mock import patch, MagicMock
from app.services.evaluator_agent import evaluate_step_progression, evaluate_scenario_success

@pytest.mark.asyncio
@patch('app.services.evaluator_agent.client.models.generate_content')
@patch('app.services.evaluator_agent.supabase')
async def test_evaluate_step_progression_success(mock_supabase, mock_generate):
    """Teste si un bon message valide l'étape et incrémente le pointeur."""
    # 1. Simuler le scénario actif récupéré depuis Supabase
    mock_select = mock_supabase.table().select().eq().eq().execute
    mock_select.return_value.data = [{
        "id": "scenario-123",
        "current_step_index": 0,
        "steps": [
            {"target_grammar_or_vocab": ["Hei", "God dag"]}
        ]
    }]

    # 2. Simuler la réponse de Gemini ("OUI" l'apprenant a bien utilisé le vocabulaire)
    mock_generate.return_value.text = "OUI"

    # 3. Exécuter l'évaluation
    result = await evaluate_step_progression(user_id="fake-user", user_message="Hei! Hvordan går det?")

    # 4. Vérifications
    assert result is True
    assert mock_generate.called
    # Vérifier que l'update de la DB a été appelé pour incrémenter l'index
    mock_update = mock_supabase.table().update().eq().execute
    assert mock_update.called


@pytest.mark.asyncio
@patch('app.services.evaluator_agent.client.models.generate_content')
async def test_evaluate_scenario_success_true(mock_generate):
    """Teste la macro-évaluation de fin de leçon."""
    # Simuler Gemini confirmant que l'objectif est atteint
    mock_generate.return_value.text = "OUI"
    
    chat_history = [
        {"role": "agent", "content": "Peux-tu commander un café ?"},
        {"role": "user", "content": "Jeg vil gjerne ha en kaffe, takk."}
    ]
    
    result = await evaluate_scenario_success(
        user_id="fake-user", 
        chat_history=chat_history, 
        objective="Commander à boire"
    )
    
    assert result is True
    assert mock_generate.called