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

class ScenarioRequest(BaseModel):
    objective: str = Field(..., description="L'objectif pédagogique souhaité par l'apprenant")
    
class ResourceRequest(BaseModel):
    type: str = Field(..., description="'image' ou 'audio'")
    prompt_or_text: str = Field(..., description="Le texte à vocaliser ou le prompt en anglais pour l'image")

class ScenarioStep(BaseModel):
    step_id: int
    activity_type: str = Field(..., description="Ex: 'Vocabulaire', 'Jeu de rôle', 'Traduction'")
    description: str = Field(..., description="La consigne pédagogique pour le Tuteur")
    target_grammar_or_vocab: List[str] = Field(..., description="Les mots ou règles à placer")
    resource_needed: Optional[ResourceRequest] = Field(None, description="Ressource multimédia si nécessaire")

class PedagogicalScenario(BaseModel):
    objective: str = Field(..., description="L'objectif visé par la leçon")
    estimated_duration_minutes: int
    steps: List[ScenarioStep] = Field(..., description="La chronologie des activités")