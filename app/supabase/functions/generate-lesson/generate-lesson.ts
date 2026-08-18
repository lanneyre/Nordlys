import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { GoogleGenerativeAI } from 'https://esm.sh/@google/generative-ai';
console.log("Fonction 'generate-lesson' v10 (Catalogue + Quiz + Memory) démarrée");
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};
serve(async (req)=>{
  if (req.method === 'OPTIONS') return new Response('ok', {
    headers: corsHeaders
  });
  try {
    // 1. INIT
    const supabaseClient = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_ANON_KEY') ?? '', {
      global: {
        headers: {
          Authorization: req.headers.get('Authorization')
        }
      }
    });
    const apiKey = Deno.env.get('GEMINI_API_KEY');
    if (!apiKey) throw new Error("Clé API Gemini manquante");
    const { userMessage, userId, saveToLog = true } = await req.json();
    // 2. DATA USER
    const { data: profile } = await supabaseClient.from('profiles').select('*').eq('id', userId).single();
    // 3. HISTORIQUE (MÉMOIRE)
    const { data: historyData } = await supabaseClient.from('learning_logs').select('content, created_at').eq('user_id', userId).order('created_at', {
      ascending: false
    }).limit(6);
    const reversedHistory = historyData ? historyData.reverse() : [];
    let conversationContext = "";
    reversedHistory.forEach((log)=>{
      if (log.content && typeof log.content === 'object') {
        const uMsg = log.content.user_msg || "";
        const aMsg = log.content.ai_response || "" // On pourrait tronquer pour économiser les tokens
        ;
        conversationContext += `Eleve: ${uMsg}\nCoach: ${aMsg}\n`;
      }
    });
    // Variables
    const userName = profile?.username || "Apprenant";
    const currentLevel = profile?.current_level || "A0";
    const rawObjective = profile?.target_level || "Non défini";
    const modesArray = (profile?.learning_mode || "Ludique 🎮").split(',');
    const currentStyle = modesArray[Math.floor(Math.random() * modesArray.length)].trim();
    const logCount = historyData?.length || 0;
    // 4. LOGIQUE HUD (Intelligent)
    const showHud = !saveToLog || logCount === 0;
    const hudInstruction = showHud ? `AFFICHE CE HUD AU DÉBUT DE TA RÉPONSE :\n| 👤 Élève | 📊 Niveau | 🎯 Objectif | 🎭 Mode |\n| :--- | :--- | :--- | :--- |\n| ${userName} | ${currentLevel} | "${rawObjective}" | ${currentStyle} |\n\n` : `N'AFFICHE PAS LE TABLEAU/HUD DANS CE MESSAGE.`;
    // 5. LE PROMPT COMPLET
    const SYSTEM_PROMPT = `
    Tu es "Nordlys", le coach de ${userName} (Niveau ${currentLevel}).
    Style actuel : ${currentStyle}.
    Objectif : "${rawObjective}".

    **MÉMOIRE DE CONVERSATION :**
    ${conversationContext}

    **INSTRUCTION D'AFFICHAGE :**
    ${hudInstruction}

    ---

    **CATALOGUE D'ACTIVITÉS (Pioche dedans pour varier) :**
    
    * **TYPE A : "Le Traducteur Inversé" (Drill)**
      - Tu donnes une liste de phrases en Français.
      - L'élève doit traduire en Norvégien.
      - *Format JSON :* Utilise le type "quiz" pour demander 3 à 5 traductions d'un coup.

    * **TYPE B : "Texte à Trous" (Grammaire)**
      - Phrases norvégiennes avec trous \`[ ... ]\`.
      - *Format JSON :* Utilise le type "quiz" si tu mets plusieurs phrases, ou "input" pour une seule.

    * **TYPE C : "Jeu de Rôle" (Situation)**
      - Tu définis un contexte (Café, Gare, Rando).
      - Tu joues l'interlocuteur.
      - *Format JSON :* Utilise "input" pour la réponse de l'élève.

    * **TYPE D : "Le Détective" (Correction)**
      - Tu donnes une phrase avec des fautes, l'élève corrige.
      - *Format JSON :* Utilise "input".

    * **TYPE E : "Flashcard" (Vocabulaire)**
      - Tu donnes un mot, l'élève doit l'utiliser dans une phrase.
    
    * **TYPE F : "Compréhension Orale" (Écoute / Transcription / Résumé)**n+      - Fournis un court texte audio (ou sa transcription) en norvégien. Propose à l'élève soit de transcrire mot à mot (transcription), soit de produire un résumé bref en français.
      - Si tu fournis un "audio", fournis aussi une transcription de référence séparée pour la correction (l'IA peut simuler l'audio en donnant le texte à écouter).
      - *Format JSON :* Utilise le type "input" (placeholder: "Transcris ou résume ici...") et indique dans le message si tu attends une "transcription" ou un "résumé".

    * **TYPE G : "Débat" (Argumentation)**n+      - Propose un thème et mène un débat à tours alternés : l'IA commence (proposition d'argument), l'utilisateur répond, l'IA réplique, etc. Le but est d'entraîner l'argumentation et la prise de parole.
      - IMPORTANT : N'EXÉCUTE PAS CE TYPE SI L'ÉLÈVE EST EN DESSOUS DU NIVEAU B1. Si le profil indique un niveau inférieur à "B1", propose une version simplifiée (discussion guidée / jeu de rôle) au lieu d'un vrai débat.
      - *Format JSON :* Utilise le type "input" pour chaque prise de parole. Dans la réponse initiale du modèle inclure un petit objet métadonnée humainement lisible (dans le texte) qui précise qui commence et quel est le "turn" courant.

    * **TYPE H : "Le Peintre Aveugle" (Description d'image)**
      - Tu imagines une scène amusante, absurde ou typiquement norvégienne (ex: un élan qui mange une gaufre à Oslo).
      - Tu demandes à l'élève de décrire ce qu'il voit.
      - 🚨 RÈGLE ABSOLUE : Le JSON de fin DOIT OBLIGATOIREMENT être de type "image_description". NE METS JAMAIS "type": "input".
      - Tu DOIS inclure le champ "image_prompt" contenant la description détaillée en ANGLAIS.


    ---

    **RÈGLE D'OR - AUDIO & VISUEL :**
    Dès que tu écris un mot ou une phrase en **Norvégien** (et uniquement en Norvégien), tu DOIS l'encadrer avec des doubles crochets comme ceci : [[Tekst på norsk]].
    Exemple : "Le mot pour bonjour est [[God morgen]]."
    Cela permettra à l'application de le lire à haute voix.

    **FORMAT TECHNIQUE OBLIGATOIRE (JSON à la fin) :**
    Si tu attends une réponse de l'élève, termine TOUJOURS par le séparateur "@@@JSON@@@" suivi du code.

    1. Pour une seule réponse (ex: Jeu de rôle, Conversation) :
    @@@JSON@@@
    { "ui_action": { "type": "input", "placeholder": "Ta réponse...", "label": "Envoyer" } }

    2. Pour une série de questions (ex: Traduction de 3 phrases, Quiz) :
    @@@JSON@@@
    { 
      "ui_action": { 
        "type": "quiz", 
        "questions": ["Traduire 'Chien'", "Traduire 'Maison'", "Traduire 'Fjord'"], 
        "label": "Valider mes réponses" 
      } 
    }
    `;
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-pro",
      systemInstruction: SYSTEM_PROMPT
    });
    const result = await model.generateContent(userMessage);
    const fullText = result.response.text();
    // 6. SAUVEGARDE (Sauf si drapeau init)
    if (saveToLog) {
      await supabaseClient.from('learning_logs').insert({
        user_id: userId,
        activity_type: 'CONVERSATION',
        content: {
          user_msg: userMessage,
          ai_response: fullText,
          style_used: currentStyle
        }
      });
    }
    // 7. RETOUR (Brut, Flutter nettoie)
    return new Response(JSON.stringify({
      reply: fullText,
      metadata: {}
    }), {
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      }
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: error.message
    }), {
      status: 500,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      }
    });
  }
});
