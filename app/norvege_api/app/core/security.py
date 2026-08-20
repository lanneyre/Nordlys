import jwt
from fastapi import WebSocketException, status
from app.core.config import settings
from app.core.supabase_client import supabase

# URL publique où Supabase expose ses clés de sécurité (JWKS)
jwks_url = f"{settings.SUPABASE_URL}/auth/v1/jwks"
jwks_client = jwt.PyJWKClient(jwks_url, headers={"apikey": settings.SUPABASE_PUBLISHABLE_KEY})

def verify_supabase_token(token: str) -> dict:
    """
    Décode et valide dynamiquement le token JWT généré par Supabase (compatible ECC/ES256).
    """
    try:
        # Le client Supabase s'occupe de valider le token sur ses propres serveurs
        response = supabase.auth.get_user(token)
        
        # Si le token est valide, on retourne un dictionnaire contenant l'ID utilisateur
        # (sous la clé "sub", comme le faisait PyJWT, pour ne pas casser ton code)
        return {"sub": response.user.id}
                
    except Exception as e:
        raise WebSocketException(
            code=status.WS_1008_POLICY_VIOLATION, 
            reason=f"Token invalide ou expiré : {str(e)}"
        )