import base64
import httpx
from fastapi import HTTPException
from app.core.config import settings

# Point d'accès à l'API d'Inférence de Hugging Face (Modèle au choix, ici SDXL)

async def generate_image(prompt: str) -> str:
    """
    Génère une image via l'API Hugging Face à partir d'un prompt en anglais.
    Retourne l'image encodée en Base64 prête à être affichée dans Flutter.
    """
    if not hasattr(settings, 'HF_API_KEY') or not settings.HF_API_KEY:
        raise HTTPException(status_code=500, detail="La clé API Hugging Face n'est pas configurée.")

    headers = {"Authorization": f"Bearer {settings.HF_API_KEY}"}
    payload = {"inputs": prompt}

    # Utilisation de httpx pour des requêtes HTTP asynchrones performantes
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(settings.HF_IMAGE_API_URL, headers=headers, json=payload, timeout=45.0)
            response.raise_for_status()

            # L'API Hugging Face renvoie directement les bytes de l'image
            image_bytes = response.content
            base64_encoded = base64.b64encode(image_bytes).decode('utf-8')
            
            return f"data:image/jpeg;base64,{base64_encoded}"

        except httpx.HTTPStatusError as e:
            raise HTTPException(status_code=500, detail=f"Erreur de l'API Hugging Face : {e.response.text}")
        except httpx.RequestError as e:
            raise HTTPException(status_code=500, detail=f"Erreur réseau lors de la génération d'image : {str(e)}")

async def generate_audio(text: str) -> str:
    """
    Génère un fichier audio TTS (Text-To-Speech) en norvégien.
    Retourne le flux audio encodé en Base64.
    """
    # Ce bloc sera à implémenter selon le service TTS choisi 
    # (Google Cloud TTS, ElevenLabs, ou un modèle vocal Hugging Face)
    pass