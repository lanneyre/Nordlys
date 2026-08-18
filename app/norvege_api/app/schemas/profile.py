from pydantic import BaseModel, Field
from typing import Optional

class ProfileUpdate(BaseModel):
    username: Optional[str] = Field(None, description="Nom d'utilisateur de l'apprenant")
    current_level: Optional[str] = Field(None, description="Niveau CECRL actuel (ex: A1, A2)")
    target_level: Optional[str] = Field(None, description="Objectif visé (ex: B2)")
    learning_mode: Optional[str] = Field(None, description="Préférences de modes d'apprentissage (ex: 'Ludique 🎮, Sérieux 📚')")

class ProfileResponse(ProfileUpdate):
    id: str = Field(..., description="UUID de l'utilisateur")
    # On peut ajouter ici d'autres champs gérés par la base de données (ex: avatar_url, xp, etc.)