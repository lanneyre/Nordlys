from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Nordlys API"
    SUPABASE_URL: str
    SUPABASE_PUBLISHABLE_KEY: str
    SUPABASE_JWT_SECRET: str # Trouvable dans le dashboard Supabase (Settings > API)
    GEMINI_API_KEY: str
    HF_API_KEY: str
    EVALUATION_COMPTEUR: int = 20  # Nombre de messages avant d'évaluer le niveau de l'apprenant
    
    class Config:
        env_file = ".env"

settings = Settings()