import json
import asyncio
from google import genai
from google.genai import types
from app.core.config import settings
from app.core.supabase_client import supabase
from app.schemas.lessons import PedagogicalScenario

client = genai.Client(api_key=settings.GEMINI_API_KEY)

async def generate_and_save_scenario(user_id: str, current_level: str, target_level: str, objective: str) -> str:
    """
    1. Demande à Gemini de générer un scénario pédagogique structuré (via Pydantic).
    2. Sauvegarde le résultat dans la table Supabase 'active_scenarios'.
    3. Retourne le scénario sous forme de dictionnaire.
    """
    system_prompt = f"""
    Tu es un ingénieur pédagogique expert en langue norvégienne.
    Conçois un scénario de leçon court et percutant.
    Niveau actuel de l'apprenant : {current_level}
    Niveau visé : {target_level}
    Objectif de l'apprenant : {objective}
    
    Découpe la leçon en 3 à 5 étapes progressives (ScenarioStep).
    Tu peux prévoir de demander des ressources (images pour illustrer, audio pour l'écoute).
    """
    
    response = client.models.generate_content(
        model=settings.GEMINI_MODEL,
        contents="Génère le scénario pédagogique.",
        config=types.GenerateContentConfig(
            system_instruction=system_prompt,
            response_mime_type="application/json",
            response_schema=PedagogicalScenario,
            temperature=0.2, # Faible créativité pour garder une structure logique
        ),
    )
    scenario_data = json.loads(response.text)

    # Fonction synchrone pour insérer en base de données via Supabase
    def insert_db():
        # Optionnel : On marque d'abord les anciens scénarios actifs comme 'completed' ou 'failed'
        supabase.table("active_scenarios")\
            .update({"status": "completed"})\
            .eq("user_id", user_id)\
            .eq("status", "in_progress")\
            .execute()

        # Insertion du nouveau scénario actif
        payload = {
            "user_id": user_id,
            "objective": scenario_data.get("objective"),
            "estimated_duration_minutes": scenario_data.get("estimated_duration_minutes"),
            "steps": scenario_data.get("steps"),
            "current_step_index": 0,
            "status": "in_progress"
        }
        res = supabase.table("active_scenarios").insert(payload).execute()
        return res.data[0] if res.data else None

    # Exécution de l'appel Supabase dans un thread séparé pour ne pas bloquer l'event loop
    saved_scenario = await asyncio.to_thread(insert_db)

    return saved_scenario