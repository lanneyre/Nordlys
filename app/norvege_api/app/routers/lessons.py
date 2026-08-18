from fastapi import APIRouter, Depends, HTTPException
from typing import List
from app.core.supabase_client import supabase
from app.routers.profile import get_current_user_id
from app.schemas.lessons import LearningLogResponse, ScenarioRequest
from app.services import scenario_agent
from app.schemas.lessons import PedagogicalScenario


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

@router.post("/scenario", response_model=dict)
async def create_lesson_scenario(request: ScenarioRequest, user_id: str = Depends(get_current_user_id)):
    """
    Génère un nouveau scénario pédagogique personnalisé pour l'utilisateur connecté
    en se basant sur son profil (niveau actuel et objectif visé).
    """
    try:
        # 1. Récupérer le profil pour connaître le niveau actuel et l'objectif global de l'apprenant
        profile_res = supabase.table('profiles').select('current_level, target_level').eq('id', user_id).single().execute()
        profile = profile_res.data or {}
        
        current_level = profile.get('current_level', 'A0')
        target_level = profile.get('target_level', 'A1')
        
        # 2. Appeler l'Agent Scénariste pour générer et sauvegarder le plan
        saved_scenario = await scenario_agent.generate_and_save_scenario(
            user_id=user_id,
            current_level=current_level,
            target_level=target_level,
            objective=request.objective
        )
        
        if not saved_scenario:
            raise HTTPException(status_code=500, detail="Échec de la création du scénario en base de données.")
            
        return saved_scenario
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur du service de scénarisation: {str(e)}")