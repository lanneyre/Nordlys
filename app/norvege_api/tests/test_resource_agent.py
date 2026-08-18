import pytest
import httpx
from unittest.mock import patch, MagicMock
from fastapi import HTTPException
from app.services.resource_agent import generate_image

@pytest.mark.asyncio
@patch('app.services.resource_agent.httpx.AsyncClient.post')
@patch('app.services.resource_agent.settings')
async def test_generate_image_success(mock_settings, mock_post):
    """Teste la génération réussie d'une image et son encodage en Base64."""
    # 1. Simuler la présence de la clé API
    mock_settings.HF_API_KEY = "fake_api_key_123"
    
    # 2. Configurer la fausse réponse HTTP de Hugging Face
    mock_response = MagicMock()
    mock_response.content = b"fake_image_data" # Bytes bruts de l'image
    mock_response.raise_for_status.return_value = None
    mock_post.return_value = mock_response

    # 3. Exécution
    result = await generate_image("A beautiful Norwegian fjord")

    # 4. Vérifications
    assert result.startswith("data:image/jpeg;base64,")
    # "fake_image_data" encodé en base64 donne "ZmFrZV9pbWFnZV9kYXRh"
    assert "ZmFrZV9pbWFnZV9kYXRh" in result 
    mock_post.assert_called_once()


@pytest.mark.asyncio
@patch('app.services.resource_agent.httpx.AsyncClient.post') # On mocke aussi httpx par sécurité
@patch('app.services.resource_agent.settings')
async def test_generate_image_missing_api_key(mock_settings, mock_post):
    """Teste que l'agent bloque la requête si la clé API est absente."""
    # Simuler l'absence de clé
    mock_settings.HF_API_KEY = ""
    
    with pytest.raises(HTTPException) as exc_info:
        await generate_image("A beautiful Norwegian fjord")
        
    assert exc_info.value.status_code == 500
    assert "clé API Hugging Face n'est pas configurée" in str(exc_info.value.detail)


@pytest.mark.asyncio
@patch('app.services.resource_agent.httpx.AsyncClient.post')
@patch('app.services.resource_agent.settings')
async def test_generate_image_http_error(mock_settings, mock_post):
    """Teste la gestion d'une erreur renvoyée par le serveur Hugging Face (ex: 401, 503)."""
    mock_settings.HF_API_KEY = "fake_api_key_123"
    
    # Simuler une exception HTTPStatusError (ex: Modèle en cours de chargement)
    mock_request = MagicMock()
    mock_response = MagicMock()
    mock_response.text = "Model loading"
    
    mock_post.side_effect = httpx.HTTPStatusError(
        "Erreur serveur", request=mock_request, response=mock_response
    )

    with pytest.raises(HTTPException) as exc_info:
        await generate_image("A beautiful Norwegian fjord")
        
    assert exc_info.value.status_code == 500
    assert "Erreur de l'API Hugging Face" in str(exc_info.value.detail)


@pytest.mark.asyncio
@patch('app.services.resource_agent.httpx.AsyncClient.post')
@patch('app.services.resource_agent.settings')
async def test_generate_image_network_error(mock_settings, mock_post):
    """Teste la gestion d'une coupure réseau ou d'un timeout."""
    mock_settings.HF_API_KEY = "fake_api_key_123"
    
    # Simuler une coupure réseau pure (RequestError)
    mock_request = MagicMock()
    mock_post.side_effect = httpx.RequestError("Timeout", request=mock_request)

    with pytest.raises(HTTPException) as exc_info:
        await generate_image("A beautiful Norwegian fjord")
        
    assert exc_info.value.status_code == 500
    assert "Erreur réseau" in str(exc_info.value.detail)