from fastapi import WebSocket

class ConnectionManager:
    def __init__(self):
        # Liste pour garder une trace des connexions actives
        self.active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        """Accepte la connexion et l'ajoute à la liste."""
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        """Retire la connexion de la liste (ex: quand l'utilisateur quitte)."""
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        """Envoie un message texte simple à une connexion spécifique."""
        await websocket.send_text(message)

    async def send_json(self, data: dict, websocket: WebSocket):
        """Envoie des données structurées en JSON (très utile pour l'app Flutter)."""
        await websocket.send_json(data)

# On instancie un singleton qui sera importé dans nos routes
manager = ConnectionManager()