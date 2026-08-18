import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
// On importe le SDK officiel de Google adapté pour Deno/Supabase
import { GoogleGenerativeAI } from "npm:@google/generative-ai";
// Définition des en-têtes CORS pour autoriser l'application Flutter à appeler la fonction
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};
serve(async (req)=>{
  // 1. Gestion du "Preflight" (Sécurité CORS)
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }
  try {
    // 2. On récupère les données envoyées par Flutter
    const { conversation } = await req.json();
    if (!conversation) {
      throw new Error("La conversation est vide ou manquante.");
    }
    // 3. Récupération de votre clé API Gemini depuis les secrets Supabase
    const apiKey = Deno.env.get('GEMINI_API_KEY');
    if (!apiKey) {
      throw new Error("La clé API Gemini est introuvable.");
    }
    // 4. Initialisation de Gemini
    const genAI = new GoogleGenerativeAI(apiKey);
    // Le fameux System Prompt ultra-strict
    const systemPrompt = `Tu es un examinateur expert en langue norvégienne.
Analyse la conversation suivante entre un utilisateur et son coach.
Ton SEUL objectif est de déterminer le niveau CECRL actuel de l'utilisateur (A0, A1, A2, B1, B2, C1 ou C2).
Tu dois te baser sur la complexité de son vocabulaire, sa grammaire et sa compréhension.

RÈGLE ABSOLUE : Ta réponse doit faire EXACTEMENT 2 caractères. Ne donne aucune explication.
Exemples de réponses valides : A0, A1, A2, B1, B2, C1, C2.`;
    // On configure le modèle Gemini 2.5 Pro
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-pro",
      systemInstruction: systemPrompt,
      generationConfig: {
        temperature: 0.1,
        maxOutputTokens: 5
      }
    });
    // 5. Appel à l'IA avec la conversation
    const result = await model.generateContent(`Voici la conversation :\n\n${conversation}`);
    const level = result.response.text().trim().toUpperCase();
    // 6. On renvoie la réponse à Flutter !
    return new Response(JSON.stringify({
      level: level
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      }
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: error.message
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 400
    });
  }
});
