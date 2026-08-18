import jwt
from fastapi import WebSocketException, status
from app.core.config import settings

def verify_supabase_token(token: str) -> dict:
    """
    Décode et valide le token JWT généré par Supabase.
    Retourne le payload du token (qui contient l'ID de l'utilisateur) si valide.
    Lève une exception WebSocket si le token est invalide ou expiré.
    """
    try:
        # Supabase utilise l'algorithme HS256 par défaut
        payload = jwt.decode(
            token, 
            settings.SUPABASE_JWT_SECRET, 
            algorithms=["HS256"],
            options={"verify_aud": False} # Désactive la vérification de l'audience pour simplifier
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise WebSocketException(
            code=status.WS_1008_POLICY_VIOLATION, 
            reason="Le token est expiré."
        )
    except jwt.InvalidTokenError:
        raise WebSocketException(
            code=status.WS_1008_POLICY_VIOLATION, 
            reason="Token invalide."
        )