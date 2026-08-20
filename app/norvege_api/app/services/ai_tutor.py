import random
import asyncio
from google import genai
from google.genai import types
from app.core.config import settings
from app.core.supabase_client import supabase
from app.schemas.chat_ws import AgentResponse
from app.services.scenario_agent import generate_and_save_scenario

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

    # 2. Récupération du scénario actif (NOUVEAU)
    scenario_res = supabase.table('active_scenarios').select('*').eq('user_id', user_id).execute()
    active_scenario = scenario_res.data[0] if scenario_res.data else None
    
    # --- 3. LE DÉCLENCHEUR AUTOMATIQUE (LE MAILLON MANQUANT) 👇 ---
    if not active_scenario:
        print(f"⚠️ Aucun scénario actif pour {user_name}. Génération en cours...")
        
        # On force la création d'un scénario via ton autre fichier
        active_scenario = await generate_and_save_scenario(
            user_id=user_id,
            current_level=current_level,
            target_level=raw_objective,
            objective=profile.get('objective', 'Apprendre le norvégien')
        )
        print("✅ Nouveau scénario sauvegardé en base de données !")
    # -------------------------------------------------------------
    
    scenario_instruction = ""
    if active_scenario and active_scenario.get('steps'):
        current_step_idx = active_scenario.get('current_step_index', 0)
        steps = active_scenario.get('steps', [])
        
        if current_step_idx < len(steps):
            current_step = steps[current_step_idx]
            target_vocab = ", ".join(current_step.get('target_grammar_or_vocab', []))
            
            scenario_instruction = f"""
            ---
            **SCÉNARIO PÉDAGOGIQUE EN COURS :**
            Objectif global : {active_scenario.get('objective')}
            
            **ÉTAPE ACTUELLE ({current_step_idx + 1}/{len(steps)}) :**
            Activité : {current_step.get('activity_type')}
            Consigne : {current_step.get('description')}
            Cible (à faire utiliser par l'apprenant) : {target_vocab}
            
            Ton rôle est d'animer CETTE étape précise. Adapte la conversation pour y parvenir.
            ---
            """
    # 3. Construction de la consigne du HUD       
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
    
    {scenario_instruction}
    
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

    # 5. Conversion de l'historique
    contents = []
    for msg in chat_context:
        role = "user" if msg["role"] == "user" else "model"
        contents.append(types.Content(role=role, parts=[types.Part.from_text(text=msg["content"])]))
        
    contents.append(types.Content(role="user", parts=[types.Part.from_text(text=user_message)]))

    # 6. L'Appel Magique (Gemini parse l'objet final de lui-même)
    response = client.models.generate_content(
        model=settings.GEMINI_MODEL,
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
