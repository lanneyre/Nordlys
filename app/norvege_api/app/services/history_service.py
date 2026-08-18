import asyncio
from app.core.supabase_client import supabase

async def get_recent_messages(user_id: str, limit: int = 10) -> list[dict]:
    """
    Récupère les derniers messages d'un utilisateur pour hydrater le contexte de l'IA.
    """
    def fetch():
        response = supabase.table("chat_messages").select("role, content")\
            .eq("user_id", user_id)\
            .order("created_at", desc=True)\
            .limit(limit)\
            .execute()
        return response.data

    data = await asyncio.to_thread(fetch)
    return list(reversed(data))

async def save_messages(user_id: str, user_text: str, agent_text: str):
    """
    Sauvegarde un échange complet (apprenant + IA) lié à l'utilisateur.
    """
    def insert():
        data = [
            {"user_id": user_id, "role": "user", "content": user_text},
            {"user_id": user_id, "role": "agent", "content": agent_text}
        ]
        supabase.table("chat_messages").insert(data).execute()

    await asyncio.to_thread(insert)