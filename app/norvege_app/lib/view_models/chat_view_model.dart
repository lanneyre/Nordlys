library;

import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../core/service_locator.dart';
import '../utils/app_logger.dart';
import '../env.dart';

class ChatViewModel extends ValueNotifier<Object?> {
  ChatViewModel() : super(null);

  // --- STATE ---
  final List<ChatMessage> messages = [];
  String? currentLevel;
  bool isLoading = false;

  // --- CONTROLLERS ---
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  // --- SERVICES ---
  final _authService = ServiceLocator.authService;
  final _aiService = ServiceLocator.aiService;

  // URL de ton backend FastAPI (À adapter selon ton émulateur : 10.0.2.2 pour Android)
  final String _wsUrl = Env.apiUrl;

  // --- GETTERS ---
  bool get hasMessages => messages.isNotEmpty;
  int get messageCount => messages.length;

  Future<void> initialize() async {
    try {
      isLoading = true;
      notifyListeners();

      final profile = await _authService.getProfile();
      currentLevel = profile['current_level']?.toString();

      // 1. On se connecte à la WebSocket
      await _aiService.connect(_wsUrl);

      // 2. On écoute le flux en permanence
      _aiService.messageStream?.listen(
        _handleIncomingMessage,
        onError: (error) {
          AppLogger.error('Erreur WebSocket: $error');
          isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      isLoading = false;
      AppLogger.error('Erreur lors de l\'initialisation: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Traite les données brutes reçues de la WebSocket
  void _handleIncomingMessage(dynamic rawData) {
    try {
      final String messageStr = rawData as String;
      // 1. Sécurité : On vérifie si c'est un message d'erreur en texte brut
      if (!messageStr.trim().startsWith('{')) {
        AppLogger.error("Message serveur refusé (non-JSON) : $messageStr");
        isLoading = false;
        notifyListeners();

        // Si le token a expiré, on peut forcer la déconnexion
        if (messageStr.toLowerCase().contains('token')) {
          logout();
        }
        return;
      }

      final Map<String, dynamic> data = jsonDecode(messageStr);

      // Gestion du message de confirmation de connexion (si ton backend en envoie un)
      if (data.containsKey('status') && data['status'] == 'connected') {
        AppLogger.info("WebSocket connectée et authentifiée.");
        isLoading = false;
        notifyListeners();
        // Optionnel : déclencher un premier message d'introduction
        _aiService.sendMessage("hello");
        return;
      }

      // Parsing du message de l'IA
      final incomingMessage = ChatMessage.fromWebSocketJson(data);
      _addMessage(incomingMessage);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Erreur de parsing du message entrant: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  void _addMessage(ChatMessage message) {
    messages.add(message);
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userText = text;
    messageController.clear();

    // On affiche immédiatement le message de l'apprenant
    _addMessage(ChatMessage(text: userText, isUser: true));

    isLoading = true;
    notifyListeners();

    // On injecte le texte dans le tuyau de la WebSocket (pas de await !)
    _aiService.sendMessage(userText);
  }

  Future<void> logout() async {
    _aiService.disconnect();
    await _authService.signOut();
  }

  @override
  void dispose() {
    _aiService.disconnect();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
