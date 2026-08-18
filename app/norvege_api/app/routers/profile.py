from fastapi import APIRouter, Depends, HTTPException, Header
from app.core.supabase_client import supabase
from app.core.security import verify_supabase_token
from app.schemas.profile import ProfileUpdate, ProfileResponse

router = APIRouter(prefix="/api/profile", tags=["Profile"])

def get_current_user_id(authorization: str = Header(...)) -> str:
    """Dépendance pour extraire et valider le token JWT du header Authorization."""
    try:
        token = authorization.replace("Bearer ", "")
        payload = verify_supabase_token(token)
        return payload.get("sub")
    except Exception as e:
        raise HTTPException(status_code=401, detail="Non autorisé ou token invalide")

@router.get("/", response_model=ProfileResponse)
async def get_profile(user_id: str = Depends(get_current_user_id)):
    """Récupère le profil de l'utilisateur connecté."""
    response = supabase.table('profiles').select('*').eq('id', user_id).single().execute()
    
    if not response.data:
        raise HTTPException(status_code=404, detail="Profil introuvable")
        
    return response.data

@router.patch("/", response_model=ProfileResponse)
async def update_profile(profile_data: ProfileUpdate, user_id: str = Depends(get_current_user_id)):
    """Met à jour les informations pédagogiques de l'utilisateur."""
    # On exclut les champs non renseignés (None) pour ne mettre à jour que le nécessaire
    update_payload = profile_data.model_dump(exclude_unset=True)
    
    if not update_payload:
        raise HTTPException(status_code=400, detail="Aucune donnée à mettre à jour")
        
    response = supabase.table('profiles').update(update_payload).eq('id', user_id).execute()
    
    if not response.data:
        raise HTTPException(status_code=500, detail="Erreur lors de la mise à jour")
        
    return response.data[0]