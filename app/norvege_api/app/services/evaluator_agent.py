import asyncio
from google import genai
from google.genai import types
from app.core.config import settings
from app.core.supabase_client import supabase

# Instanciation du client Gemini pour cet agent spécifique
client = genai.Client(api_key=settings.GEMINI_API_KEY)

async def auto_evaluate_level(user_id: str, chat_context: list[dict]):
    """
    Évalue silencieusement le niveau de l'utilisateur en analysant les derniers échanges
    et met à jour son profil dans Supabase.
    """
    # 1. On ne prend que les 15-20 derniers messages pour ne pas fausser l'évaluation
    recent_context = chat_context[-20:]
    
    # Formatage de la conversation en texte brut pour le LLM
    conversation_text = "\n".join(
        [f"{msg['role']}: {msg['content']}" for msg in recent_context]
    )

    system_prompt = """Tu es un examinateur expert en langue norvégienne.
    Analyse la conversation suivante entre un utilisateur et son coach.
    Ton SEUL objectif est de déterminer le niveau CECRL actuel de l'utilisateur (A0, A1, A2, B1, B2, C1 ou C2).
    Tu dois te baser sur la complexité de son vocabulaire, sa grammaire et sa compréhension.

    RÈGLE ABSOLUE : Ta réponse doit faire EXACTEMENT 2 caractères. Ne donne aucune explication.
    Exemples de réponses valides : A0, A1, A2, B1, B2, C1, C2."""

    try:
        # 2. Appel à Gemini (Température très basse pour garantir la précision)
        response = client.models.generate_content(
            model=settings.GEMINI_MODEL,
            contents=conversation_text,
            config=types.GenerateContentConfig(
                system_instruction=system_prompt,
                temperature=0.1,
                max_output_tokens=5,
            ),
        )
        
        # Nettoyage de la réponse
        level = response.text.strip().upper()

        # 3. Validation stricte et mise à jour de la base de données
        valid_levels = {"A0", "A1", "A2", "B1", "B2", "C1", "C2"}
        if level in valid_levels:
            def update_db():
                supabase.table("profiles").update({"current_level": level}).eq("id", user_id).execute()
            
            # Exécution de la mise à jour réseau dans un thread séparé
            await asyncio.to_thread(update_db)
            
    except Exception as e:
        # L'évaluation est silencieuse, on ignore l'erreur
        pass

async def evaluate_scenario_success(chat_history: str, objective: str) -> bool:
    """
    Analyse l'historique de la leçon terminée pour vérifier si l'objectif est atteint.
    """
    system_prompt = """
    Tu es un évaluateur intraitable. L'utilisateur devait atteindre l'objectif suivant : {objective}.
    Lis la transcription de la leçon. L'apprenant a-t-il maîtrisé le sujet ?
    Réponds UNIQUEMENT par "OUI" ou "NON".
    """
    # Appel à Gemini (Température 0.0)
    # Si "NON", on déclenche une fonction qui rappelle l'Agent Scénariste pour générer 
    # un nouveau PedagogicalScenario de remédiation.