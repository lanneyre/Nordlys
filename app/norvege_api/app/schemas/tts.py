from pydantic import BaseModel, Field

class TTSRequest(BaseModel):
    text: str = Field(..., description="Le texte norvégien à vocaliser")
    language: str = Field(default="no", description="Code langue (par défaut 'no' pour le norvégien)")

class TTSResponse(BaseModel):
    audio_url: str = Field(..., description="L'URL publique ou le base64 du fichier audio généré")