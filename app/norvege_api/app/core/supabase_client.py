from supabase import create_client, Client
from app.core.config import settings

# Instanciation unique du client Supabase
supabase: Client = create_client(
    settings.SUPABASE_URL, 
    settings.SUPABASE_SERVICE_ROLE_KEY
    )