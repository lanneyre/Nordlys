import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart'; // <-- LA LIGNE MAGIQUE À AJOUTER
import '../utils/app_logger.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  /// Envoie le message à l'Edge Function et retourne la réponse structurée
  Future<Map<String, dynamic>> generateLesson(
    String userMessage, {
    bool saveToLog = true,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    try {
      final response = await _client.functions.invoke(
        'generate-lesson',
        body: {
          'userMessage': userMessage,
          'userId': user.id,
          'saveToLog': saveToLog, // <--- ON ENVOIE LE DRAPEAU ICI
        },
      );

      // 👇 C'EST ICI QUE SE TROUVAIT L'ERREUR 👇
      // On force la conversion des données reçues
      final data = response.data as Map<dynamic, dynamic>;

      return {
        'reply': data['reply']?.toString() ?? "Erreur: Pas de réponse texte.",
        // On convertit proprement les métadonnées pour qu'elles soient acceptées par ChatMessage
        'metadata': data['metadata'] != null
            ? Map<String, dynamic>.from(data['metadata'])
            : null,
      };
    } catch (e) {
      throw Exception("Erreur IA: $e");
    }
  }

  Future<String?> evaluateUserLevel(List<ChatMessage> recentHistory) async {
    try {
      // 1. On prépare l'historique sous forme de texte pour l'IA
      String conversationText = recentHistory
          .map((msg) {
            return "${msg.isUser ? 'Utilisateur' : 'Coach'}: ${msg.text}";
          })
          .join('\n');

      // 2. On appelle Supabase (Edge Function) au lieu d'appeler l'IA directement
      final response = await _client.functions.invoke(
        'evaluate-level', // <-- Le nom de la future fonction sur Supabase
        body: {
          'conversation': conversationText,
          // Note : Le "System Prompt" strict (A1, A2...) sera à mettre
          // directement dans le code de l'Edge Function côté Supabase !
        },
      );

      // 3. On récupère la réponse de l'Edge Function
      final data = response.data as Map<dynamic, dynamic>;
      final level = data['level']?.toString().trim().toUpperCase() ?? '';

      // 4. On sécurise la réponse (au cas où l'IA bavarde quand même)
      final validLevels = ['A0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
      if (validLevels.contains(level)) {
        return level; // L'évaluation est un succès
      } else {
        AppLogger.warning('L\'IA a mal formaté sa réponse : $level');
        return null;
      }
    } catch (e) {
      AppLogger.error('Erreur lors de l\'évaluation : $e');
      return null;
    }
  }
}
