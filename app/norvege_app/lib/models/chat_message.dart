class ChatMessage {
  final String text; // Le contenu du message
  final bool isUser; // True = Moi, False = L'IA
  final Map<String, dynamic>?
  metadata; // Les infos cachées (Exercices, Scores...)

  ChatMessage({required this.text, required this.isUser, this.metadata});
}
