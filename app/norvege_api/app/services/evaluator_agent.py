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

async def evaluate_scenario_success(user_id: str, chat_history: list[dict], objective: str) -> bool:
    """
    Analyse l'historique de la leçon terminée pour vérifier si l'objectif global est atteint.
    Si NON, on pourrait déclencher un nouveau scénario de remédiation.
    """
    # Formatage de l'historique en texte
    conversation_text = "\n".join([f"{msg['role']}: {msg['content']}" for msg in chat_history])
    
    system_prompt = f"""
    Tu es un évaluateur intraitable. L'utilisateur devait atteindre l'objectif suivant : "{objective}".
    Lis la transcription de la leçon ci-dessous. L'apprenant a-t-il globalement maîtrisé le sujet ?
    Réponds UNIQUEMENT par "OUI" ou "NON".
    """
    
    try:
        response = client.models.generate_content(
            model=settings.GEMINI_MODEL,
            contents=conversation_text,
            config=types.GenerateContentConfig(
                system_instruction=system_prompt,
                temperature=0.0, # Zéro créativité
                max_output_tokens=5,
            ),
        )
        
        is_success = "OUI" in response.text.strip().upper()
        
        # Ici, si is_success est False, tu pourrais appeler :
        # await scenario_agent.generate_and_save_scenario(..., objective=f"Révision : {objective}")
        
        return is_success
        
    except Exception as e:
        return False
    
    
async def evaluate_step_progression(user_id: str, user_message: str) -> bool:
    """
    Vérifie silencieusement si le message de l'apprenant valide l'étape en cours.
    Si oui, incrémente le pointeur d'étape dans Supabase de manière stateless.
    """
    # 1. Récupération du scénario en cours
    scenario_res = supabase.table('active_scenarios').select('*').eq('user_id', user_id).eq('status', 'in_progress').execute()
    
    if not scenario_res.data:
        return False
        
    scenario = scenario_res.data[0]
    current_index = scenario.get('current_step_index', 0)
    steps = scenario.get('steps', [])
    
    # 2. Vérification de la validité de l'index
    if current_index >= len(steps):
        return False
        
    current_step = steps[current_index]
    targets = current_step.get('target_grammar_or_vocab', [])
    
    if not targets:
        return False

    # 3. Évaluation sémantique par l'IA (tolère les fautes de frappe ou les variations grammaticales)
    system_prompt = f"""
    Tu es un évaluateur linguistique strict. 
    Ton rôle est de vérifier si l'apprenant a réussi à utiliser les notions suivantes : {", ".join(targets)}.
    
    Message de l'apprenant : "{user_message}"
    
    Réponds UNIQUEMENT par "OUI" si la notion est globalement acquise et présente dans le message, sinon "NON".
    """
    
    response = client.models.generate_content(
        model=settings.GEMINI_MODEL,
        contents="Évalue l'acquisition.",
        config=types.GenerateContentConfig(
            system_instruction=system_prompt,
            temperature=0.0, # Zéro créativité, on veut un binaire
        ),
    )
    
    is_validated = "OUI" in response.text.strip().upper()
    
    # 4. Progression et sauvegarde (Stateless)
    if is_validated:
        new_index = current_index + 1
        # Si on dépasse le nombre d'étapes, le scénario est terminé
        status = 'completed' if new_index >= len(steps) else 'in_progress'
        
        def update_db():
            supabase.table('active_scenarios')\
                .update({'current_step_index': new_index, 'status': status})\
                .eq('id', scenario['id'])\
                .execute()
                
        # Exécution non-bloquante pour la WebSocket
        await asyncio.to_thread(update_db)
        
    return is_validated