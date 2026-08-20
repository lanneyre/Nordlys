import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/app_logger.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  WebSocketChannel? _channel;

  // Ce Stream permettra au ChatViewModel d'écouter les réponses de l'IA en temps réel
  Stream<dynamic>? get messageStream => _channel?.stream;

  /// Ouvre la connexion WebSocket et authentifie l'utilisateur
  Future<void> connect(String wsUrl) async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) throw Exception("Utilisateur non connecté");

      final token = session.accessToken;

      // Établissement de la connexion
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      AppLogger.info("WebSocket connectée à $wsUrl");

      // Envoi immédiat du token JWT comme attendu par notre backend FastAPI
      final authPayload = jsonEncode({"token": token});
      _channel!.sink.add(authPayload);
    } catch (e) {
      AppLogger.error("Erreur d'initialisation de la WebSocket: $e");
      rethrow;
    }
  }

  /// Envoie le message de l'apprenant dans le tuyau
  void sendMessage(String text) {
    if (_channel != null) {
      _channel!.sink.add(text);
      AppLogger.info("Message envoyé: $text");
    } else {
      AppLogger.error("Impossible d'envoyer, WebSocket déconnectée.");
    }
  }

  /// Ferme proprement la connexion
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    AppLogger.info("WebSocket déconnectée");
  }
}
