import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { encode } from "https://deno.land/std@0.168.0/encoding/base64.ts";
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};
serve(async (req)=>{
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }
  try {
    const { imagePrompt } = await req.json();
    if (!imagePrompt) throw new Error("Le paramètre 'imagePrompt' est requis.");
    const hfKey = Deno.env.get('HF_API_KEY');
    if (!hfKey) throw new Error("La clé HF_API_KEY est manquante sur le serveur.");
    console.log(`Génération avec Hugging Face : ${imagePrompt.substring(0, 50)}...`);
    // 🚀 LA CORRECTION EST ICI : Le nouveau routeur de Hugging Face
    const response = await fetch("https://router.huggingface.co/hf-inference/models/stabilityai/stable-diffusion-xl-base-1.0", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${hfKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        inputs: imagePrompt
      })
    });
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Erreur HF (${response.status}): ${errorText}`);
    }
    const arrayBuffer = await response.arrayBuffer();
    const base64Image = encode(new Uint8Array(arrayBuffer));
    return new Response(JSON.stringify({
      image_base64: base64Image
    }), {
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      }
    });
  } catch (error) {
    console.error("Erreur API :", error.message);
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
