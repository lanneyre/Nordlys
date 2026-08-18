import random
import asyncio
from google import genai
from google.genai import types
from app.core.config import settings
from app.core.supabase_client import supabase
from app.schemas.chat import AgentResponse

client = genai.Client(api_key=settings.GEMINI_API_KEY)

async def generate_response(user_id: str, user_message: str, chat_context: list[dict], show_hud: bool) -> AgentResponse:
    # 1. Récupération des données utilisateur (équivalent de l'étape 2 dans Deno)
    profile_res = supabase.table('profiles').select('*').eq('id', user_id).single().execute()
    profile = profile_res.data or {}
    
    user_name = profile.get('username', 'Apprenant')
    current_level = profile.get('current_level', 'A0')
    raw_objective = profile.get('target_level', 'Non défini')
    
    modes_array = [m.strip() for m in profile.get('learning_mode', 'Ludique 🎮').split(',')]
    current_style = random.choice(modes_array)

    # 2. Construction de la consigne du HUD
    hud_instruction = ""
    if show_hud:
        hud_instruction = (
            f"AFFICHE CE HUD AU DÉBUT DE TA RÉPONSE `reply` :\n"
            f"| 👤 Élève | 📊 Niveau | 🎯 Objectif | 🎭 Mode |\n"
            f"| :--- | :--- | :--- | :--- |\n"
            f"| {user_name} | {current_level} | \"{raw_objective}\" | {current_style} |\n\n"
        )
    else:
        hud_instruction = "N'AFFICHE PAS LE TABLEAU/HUD DANS CE MESSAGE."

    # 3. Le Prompt Système (nettoyé de la contrainte JSON brute)
    system_prompt = f"""
    Tu es "Nordlys", le coach de {user_name} (Niveau {current_level}).
    Style actuel : {current_style}. Objectif : "{raw_objective}".
    
    **INSTRUCTION D'AFFICHAGE :**
    {hud_instruction}
    
    **CATALOGUE D'ACTIVITÉS (Varie tes choix) :**
    * TYPE A : "Le Traducteur Inversé" -> Utilise ui_action.type = "quiz"
    * TYPE B : "Texte à Trous" -> Utilise "quiz" ou "input"
    * TYPE C : "Jeu de Rôle" -> Utilise "input"
    * TYPE D : "Le Détective" -> Utilise "input"
    * TYPE E : "Flashcard" -> Utilise "input"
    * TYPE F : "Compréhension Orale" -> Utilise "input"
    * TYPE G : "Débat" -> À partir de B1. Utilise "input"
    * TYPE H : "Le Peintre Aveugle" -> ui_action.type DOIT être "image_description". Fournis l'image_prompt en ANGLAIS.

    **RÈGLE D'OR - AUDIO :**
    Dès que tu écris un mot en norvégien, encadre-le avec des doubles crochets: [[Tekst på norsk]].
    """

    # 4. Conversion de l'historique
    contents = []
    for msg in chat_context:
        role = "user" if msg["role"] == "user" else "model"
        contents.append(types.Content(role=role, parts=[types.Part.from_text(text=msg["content"])]))
        
    contents.append(types.Content(role="user", parts=[types.Part.from_text(text=user_message)]))

    # 5. L'Appel Magique (Gemini parse l'objet final de lui-même)
    response = client.models.generate_content(
        model='gemini-2.5-pro',
        contents=contents,
        config=types.GenerateContentConfig(
            system_instruction=system_prompt,
            response_mime_type="application/json",
            response_schema=AgentResponse, 
            temperature=0.7,
        ),
    )

    # Gemini retourne un JSON parfait correspondant à AgentResponse
    return response.text

async def auto_evaluate_level(user_id: str, chat_context: list[dict]):
    """
    Évalue silencieusement le niveau de l'utilisateur en analysant les derniers échanges
    et met à jour son profil dans Supabase.
    """
    # 1. On ne prend que les 15-20 derniers messages pour ne pas fausser l'évaluation
    # avec de très vieilles erreurs si l'apprenant a progressé.
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
            model='gemini-2.5-pro',
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
        # L'évaluation est silencieuse : si elle échoue (timeout API, etc.), 
        # on ignore l'erreur pour ne pas perturber le backend.
        pass