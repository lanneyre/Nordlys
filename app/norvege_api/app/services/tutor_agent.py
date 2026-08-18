# Dans la boucle d'appel à Gemini de ton ai_tutor.py existant :
# On enrichit le System Prompt dynamiquement avec l'étape en cours.

current_step_instruction = f"""
ÉTAPE EN COURS DU SCÉNARIO : {current_step['description']}
Activité : {current_step['activity_type']}
Cible : {", ".join(current_step['target_grammar_or_vocab'])}

Ton rôle est d'animer CETTE étape précise avec l'utilisateur.
Si l'utilisateur a réussi cette étape, signale-le silencieusement dans ta réponse JSON.
"""