from typing import List,Optional

from pydantic import BaseModel, Field

class WebSocketAuthPayload(BaseModel):
    """Schéma du premier message attendu lors de l'ouverture de la WebSocket"""
    token: str = Field(..., description="Le JWT fourni par Supabase")
    
class AgentResponse(BaseModel):
    role: str = Field(default="agent")
    content: str = Field(description="La réponse ou la question de l'agent en norvégien (ou en français si on explique une règle).")
    is_correction: bool = Field(description="True si le message contient une correction d'une erreur de l'apprenant.")
    
class UIAction(BaseModel):
    type: str = Field(description="Doit être 'input', 'quiz', ou 'image_description'")
    placeholder: Optional[str] = Field(None, description="Texte du champ de saisie (pour type 'input')")
    label: Optional[str] = Field(None, description="Texte du bouton")
    questions: Optional[List[str]] = Field(None, description="Liste des éléments à traduire/compléter (pour type 'quiz')")
    image_prompt: Optional[str] = Field(None, description="Description de la scène en ANGLAIS (obligatoire si type est 'image_description')")

class AgentResponse(BaseModel):
    reply: str = Field(description="Le message texte de l'agent. RÈGLE: Encadrer le norvégien par [[ ]].")
    ui_action: UIAction = Field(description="L'action d'interface requise pour l'utilisateur.")