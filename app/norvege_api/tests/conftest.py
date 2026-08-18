import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock

# On mocke les variables d'environnement avant d'importer l'app
with patch.dict('os.environ', {
    'SUPABASE_URL': 'http://mock-url',
    'SUPABASE_KEY': 'mock-key',
    'SUPABASE_JWT_SECRET': 'super-secret-mock-key-for-testing',
    'GEMINI_API_KEY': 'mock-gemini-key'
}):
    from app.main import app
    from app.core.config import settings

@pytest.fixture
def client():
    """Fournit un client synchrone/WebSocket pour tester l'API FastAPI."""
    return TestClient(app)

@pytest.fixture
def mock_supabase():
    """Mock global pour éviter les vrais appels à la base de données."""
    with patch('app.core.supabase_client.supabase') as mock:
        yield mock