import jwt
import pytest
from fastapi import WebSocketException
from app.core.security import verify_supabase_token
from app.core.config import settings

def test_verify_valid_token():
    # Générer un faux token valide
    valid_payload = {"sub": "user-123"}
    token = jwt.encode(valid_payload, settings.SUPABASE_JWT_SECRET, algorithm="HS256")
    
    # Tester la fonction
    result = verify_supabase_token(token)
    assert result["sub"] == "user-123"

def test_verify_invalid_signature():
    # Token signé avec une mauvaise clé
    token = jwt.encode({"sub": "user-123"}, "wrong-secret", algorithm="HS256")
    
    with pytest.raises(WebSocketException) as exc_info:
        verify_supabase_token(token)
    
    assert "Token invalide" in str(exc_info.value.reason)

def test_verify_expired_token():
    # Token expiré (le claim 'exp' est dans le passé)
    payload = {"sub": "user-123", "exp": 1000000000}
    token = jwt.encode(payload, settings.SUPABASE_JWT_SECRET, algorithm="HS256")
    
    with pytest.raises(WebSocketException) as exc_info:
        verify_supabase_token(token)
        
    assert "expiré" in str(exc_info.value.reason)