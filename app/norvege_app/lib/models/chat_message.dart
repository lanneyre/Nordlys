class ChatMessage {
  final String text;
  final bool isUser;
  final Map<String, dynamic>?
  uiAction; // Remplace metadata pour plus de précision
  final String? imageData; // Accueillera la chaîne Base64 de l'Agent Ressources

  ChatMessage({
    required this.text,
    required this.isUser,
    this.uiAction,
    this.imageData,
  });

  /// Constructeur utilitaire pour parser le JSON venant de la WebSocket
  factory ChatMessage.fromWebSocketJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['reply'] ?? '',
      isUser: false, // Les messages WS viennent toujours de l'IA
      uiAction: json['ui_action'],
      imageData: json['image_data'],
    );
  }

  // Getter de rétrocompatibilité pour ne pas casser ton message_bubble.dart tout de suite
  Map<String, dynamic>? get metadata =>
      uiAction != null ? {'ui_action': uiAction} : null;
}
