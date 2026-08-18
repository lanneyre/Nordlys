from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Import de notre nouveau routeur
from app.routers import chat_ws, lessons, profile, tts

app = FastAPI(title="Norvege API", description="Backend pédagogique et orchestration IA")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Enregistrement de la route WebSocket
app.include_router(chat_ws.router)
app.include_router(lessons.router)
app.include_router(profile.router)
app.include_router(tts.router)


@app.get("/")
async def root():
    return {"message": "Velkommen til Norvege API"}