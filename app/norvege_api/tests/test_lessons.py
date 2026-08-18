from unittest.mock import patch
from app.main import app
from app.routers.profile import get_current_user_id

def override_get_current_user_id():
    return "fake-user-uuid"

# Surcharge de la dépendance de sécurité pour ce fichier de test
app.dependency_overrides[get_current_user_id] = override_get_current_user_id

@patch('app.routers.lessons.supabase')
def test_get_learning_logs(mock_supabase, client):
    # Configuration du mock Supabase pour renvoyer une fausse réponse
    mock_execute = mock_supabase.table().select().eq().order().limit().execute
    mock_execute.return_value.data = [
        {"id": 1, "user_id": "fake-user-uuid", "activity_type": "QUIZ", "content": {}, "created_at": "2026-08-18"}
    ]

    response = client.get("/api/lessons/logs?limit=5")
    
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["activity_type"] == "QUIZ"
    assert data[0]["user_id"] == "fake-user-uuid"
    
@patch('app.routers.lessons.scenario_agent.generate_and_save_scenario')
@patch('app.routers.lessons.supabase')
def test_create_lesson_scenario(mock_supabase, mock_generate_scenario, client):
    # 1. Configurer le mock Supabase pour le profil de l'utilisateur
    mock_execute = mock_supabase.table().select().eq().single().execute
    mock_execute.return_value.data = {
        "current_level": "A1",
        "target_level": "B1"
    }

    # 2. Configurer le mock de l'Agent Scénariste (pour ne pas appeler Gemini)
    mock_generate_scenario.return_value = {
        "id": "scenario-uuid-789",
        "user_id": "fake-user-uuid",
        "objective": "Acheter du pain",
        "estimated_duration_minutes": 15,
        "steps": [],
        "current_step_index": 0,
        "status": "in_progress"
    }

    # 3. Exécuter la requête HTTP POST comme le ferait Flutter
    payload = {"objective": "Acheter du pain"}
    response = client.post("/api/lessons/scenario", json=payload)

    # 4. Vérifications
    assert response.status_code == 200
    data = response.json()
    
    assert data["id"] == "scenario-uuid-789"
    assert data["objective"] == "Acheter du pain"
    
    # On vérifie que le routeur a bien appelé l'agent avec les bonnes données du profil
    mock_generate_scenario.assert_called_once_with(
        user_id="fake-user-uuid",
        current_level="A1",
        target_level="B1",
        objective="Acheter du pain"
    )