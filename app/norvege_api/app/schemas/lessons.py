from pydantic import BaseModel, Field
from typing import Any, Dict, List, Optional

class LearningLogResponse(BaseModel):
    id: int
    user_id: str
    activity_type: str = Field(..., description="Type d'activité (ex: CONVERSATION, QUIZ, IMAGE)")
    content: Dict[str, Any] = Field(..., description="Contenu brut de l'exercice (historique JSON)")
    score: Optional[int] = Field(default=0, description="Score obtenu par l'apprenant pour cette activité")
    mistakes_made: Optional[List[str]] = Field(default_factory=list, description="Liste des erreurs commises par l'apprenant")
    created_at: str