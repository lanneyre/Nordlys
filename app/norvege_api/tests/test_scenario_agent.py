import pytest
import json
from unittest.mock import patch
from app.services.scenario_agent import generate_and_save_scenario

@pytest.mark.asyncio
@patch('app.services.scenario_agent.client.models.generate_content')
@patch('app.services.scenario_agent.supabase')
async def test_generate_and_save_scenario(mock_supabase, mock_generate):
    # 1. Configurer le faux retour JSON de Gemini pour le scénario
    fake_scenario_dict = {
        "objective": "Maîtriser les salutations",
        "estimated_duration_minutes": 10,
        "steps": [
            {
                "step_id": 1,
                "activity_type": "Vocabulaire",
                "description": "Apprendre à dire bonjour",
                "target_grammar_or_vocab": ["Hei", "God dag"],
                "resource_needed": None
            }
        ]
    }
    
    # Simuler le texte de réponse de Gemini
    mock_generate.return_value.text = json.dumps(fake_scenario_dict)

    # 2. Configurer le mock Supabase pour l'insertion
    mock_insert_execute = mock_supabase.table().insert().execute
    mock_insert_execute.return_value.data = [{
        "id": "scenario-uuid-123",
        "user_id": "fake-uuid",
        "objective": "Maîtriser les salutations",
        "estimated_duration_minutes": 10,
        "steps": fake_scenario_dict["steps"],
        "current_step_index": 0,
        "status": "in_progress"
    }]

    # 3. Exécuter la fonction de l'agent
    result = await generate_and_save_scenario(
        user_id="fake-uuid",
        current_level="A0",
        target_level="A1",
        objective="Maîtriser les salutations"
    )

    # 4. Vérifications
    assert result is not None
    assert result["id"] == "scenario-uuid-123"
    assert result["objective"] == "Maîtriser les salutations"
    assert len(result["steps"]) == 1
    assert result["current_step_index"] == 0
    assert mock_generate.called
    assert mock_supabase.table.called