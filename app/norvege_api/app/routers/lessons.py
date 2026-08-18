from fastapi import APIRouter, Depends, HTTPException
from typing import List
from app.core.supabase_client import supabase
from app.routers.profile import get_current_user_id
from app.schemas.lessons import LearningLogResponse

router = APIRouter(prefix="/api/lessons", tags=["Lessons"])

@router.get("/logs", response_model=List[LearningLogResponse])
async def get_learning_logs(limit: int = 20, user_id: str = Depends(get_current_user_id)):
    """Récupère l'historique d'apprentissage de l'utilisateur."""
    response = supabase.table('learning_logs')\
        .select('*')\
        .eq('user_id', user_id)\
        .order('created_at', desc=True)\
        .limit(limit)\
        .execute()
        
    # Retourne une liste vide si aucun historique, pas besoin de lever une erreur 404
    return response.data or []