/// ViewModel pour ChatScreen
/// Sépare la logique du chat de l'UI
/// Gère les messages, l'IA et l'évaluation
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../core/service_locator.dart';
import '../utils/app_logger.dart';

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
  final _aiService = ServiceLocator.aiService;  // ✅ Utilise ServiceLocator

  // --- GETTERS ---
  bool get hasMessages => messages.isNotEmpty;
  int get messageCount => messages.length;
  Future<void> initialize() async {
    try {
      isLoading = true;
      notifyListeners();

      // Récupérer le niveau courant de l'utilisateur
      try {
        final profile = await _authService.getProfile();
        currentLevel = profile['current_level']?.toString();
      } catch (e) {
        AppLogger.error('Impossible de récupérer le profil: $e');
      }

      await _startConversation();
    } catch (e) {
      isLoading = false;
      AppLogger.error('Erreur lors de l\'initialisation: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Démarrer la conversation avec l'IA
  Future<void> _startConversation() async {
    try {
      final response = await _aiService.generateLesson(
        'hello', // Message initial simple
        saveToLog: false,
      );
      final parsed = _parseAiResponse(response['reply']);

      _addMessage(
        ChatMessage(
          text: parsed['text'],
          isUser: false,
          metadata: parsed['metadata'],
        ),
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      AppLogger.error('Erreur au démarrage: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Parser la réponse de l'IA (texte + JSON metadata)
  Map<String, dynamic> _parseAiResponse(String rawText) {
    const delimiter = "@@@JSON@@@";

    if (rawText.contains(delimiter)) {
      final parts = rawText.split(delimiter);
      final visibleText = parts[0].trim();
      final jsonPart = parts[1].trim();

      try {
        final cleanJson = jsonPart
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final parsed = jsonDecode(cleanJson);
        return {'text': visibleText, 'metadata': parsed};
      } catch (e) {
        AppLogger.error('Erreur de parsing JSON: $e');
      }
    }
    return {'text': rawText, 'metadata': null};
  }

  /// Ajouter un message à la liste
  void _addMessage(ChatMessage message) {
    messages.add(message);
    notifyListeners();

    // Scroller vers le bas
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

  /// Envoyer un message utilisateur
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userText = text;
    messageController.clear();

    _addMessage(ChatMessage(text: userText, isUser: true));

    try {
      isLoading = true;
      notifyListeners();

      // Générer la réponse de l'IA
      final response = await _aiService.generateLesson(userText);
      final parsed = _parseAiResponse(response['reply']);
      _addMessage(
        ChatMessage(
          text: parsed['text'],
          isUser: false,
          metadata: parsed['metadata'],
        ),
      );

      // Vérifier si on doit déclencher une évaluation (tous les 20 messages)
      if (messages.isNotEmpty && messages.length % 20 == 0) {
        await _triggerInvisibleEvaluation();
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      AppLogger.error('Erreur lors de l\'envoi: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Déclencher une évaluation silencieuse du niveau
  Future<void> _triggerInvisibleEvaluation() async {
    AppLogger.info('🕵️‍♂️ Déclenchement de l\'évaluation silencieuse...');

    try {
      // Récupérer les 20 derniers messages
      final chronologicalMessages = messages
          .skip(messages.length > 20 ? messages.length - 20 : 0)
          .toList();

      // Évaluer le niveau utilisateur
      final newLevel = await _aiService.evaluateUserLevel(
        chronologicalMessages,
      );

      if (newLevel != null && newLevel.isNotEmpty) {
        await _authService.updateCurrentLevel(newLevel);
        currentLevel = newLevel;
        notifyListeners();

        AppLogger.success(
          'Évaluation terminée ! Nouveau niveau CECRL : $newLevel',
        );
      }
    } catch (e) {
      AppLogger.error('Erreur pendant l\'évaluation silencieuse : $e');
      // Ne pas relancer l'erreur, c'est un processus silencieux
    }
  }

  /// Se déconnecter
  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      AppLogger.error('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
