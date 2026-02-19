import 'package:flutter/material.dart';
import 'dart:convert';
import '../l10n/app_localizations.dart';
import '../utils/app_logger.dart';
import 'package:norvege_app/widgets/chat/empty_chat.dart';
import 'package:norvege_app/widgets/chat/message_bubble.dart';
import 'package:norvege_app/widgets/chat/message_input_bar.dart';

import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'profile_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _aiService = AiService();
  final _authService = AuthService();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];

  String? _currentLevel;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startConversation();
    });
  }

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
        AppLogger.error('Erreur de parsing JSON Flutter: $e');
      }
    }
    return {'text': rawText, 'metadata': null};
  }

  Future<void> _startConversation() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      // Récupérer le niveau courant de l'utilisateur pour gérer certaines activités (ex: débat B1+)
      try {
        final profile = await _authService.getProfile();
        _currentLevel = profile['current_level']?.toString();
      } catch (e) {
        // Ne pas bloquer si impossible de récupérer le profil
        AppLogger.error('Impossible de récupérer le profil: $e');
      }
      final response = await _aiService.generateLesson(
        l10n.chatHello,
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.chatAiConnectionError(e.toString())),
            backgroundColor: AppColors.messagekO,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text;
    _controller.clear();

    _addMessage(ChatMessage(text: userText, isUser: true));

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final response = await _aiService.generateLesson(userText);
      final parsed = _parseAiResponse(response['reply']);
      _addMessage(
        ChatMessage(
          text: parsed['text'],
          isUser: false,
          metadata: parsed['metadata'],
        ),
      );
      // --- 🎯 LE DÉCLENCHEUR EST ICI ---
      // On vérifie s'il y a un multiple de 20 messages (ex: 20, 40, 60...)
      if (_messages.isNotEmpty && _messages.length % 20 == 0) {
        _triggerInvisibleEvaluation();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.chatGenericError(e.toString())),
          backgroundColor: AppColors.messagekO,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _triggerInvisibleEvaluation() async {
    AppLogger.info('🕵️‍♂️ Déclenchement de l\'évaluation silencieuse...');

    try {
      // 1. On récupère les 20 derniers messages
      // (Si votre ListView utilise reverse: true, les messages les plus récents sont au début de la liste,

      // On saute tout le début pour ne garder que les 20 derniers messages
      final chronologicalMessages = _messages
          .skip(_messages.length > 20 ? _messages.length - 20 : 0)
          .toList();
      // (Plus besoin du .reversed car ils sont déjà dans le bon sens !)
      // 2. On appelle notre AiService
      final aiService = AiService();
      final newLevel = await aiService.evaluateUserLevel(chronologicalMessages);

      // 3. Si l'IA a bien renvoyé un niveau, on met à jour la base de données
      if (newLevel != null && newLevel.isNotEmpty) {
        final authService = AuthService();
        await authService.updateCurrentLevel(newLevel);

        AppLogger.success(
          'Évaluation terminée ! Nouveau niveau CECRL : $newLevel',
        );

        // Optionnel : Vous pouvez afficher un petit message pour féliciter l'utilisateur !
        // if (mounted) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text("🎉 Votre niveau a été réévalué : $newLevel !"),
        //       backgroundColor: AppColors.vibrantOrange,
        //     ),
        //   );
        // }
      }
    } catch (e) {
      AppLogger.error('Erreur pendant l\'évaluation silencieuse : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.deepBlue,
      appBar: AppBar(
        // 1. LE LOGO À GAUCHE
        leading: Padding(
          padding: const EdgeInsets.all(8.0), // Un peu d'espace
          child: Hero(
            // Petit effet sympa si on change de page
            tag: 'app_logo',
            child: Image.asset('assets/Wolf.png'),
          ),
        ),

        // 2. LE NOM AU MILIEU
        title: Text(
          l10n.chatScreenTitle,
          style: const TextStyle(
            color: AppColors.deepBlue,
            fontWeight: FontWeight.w900, // Très gras pour faire "Logo"
            letterSpacing: 1.5, // Espacement des lettres pour le style
            fontSize: 20,
          ),
        ),

        // 3. LES BOUTONS À DROITE (Profil & Déconnexion)
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textDark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const EmptyChat()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(
                        message: _messages[index],
                        onReply: (text) {
                          _controller.text = text;
                        },
                        onSend: (text) {
                          _controller.text = text;
                          _sendMessage();
                        },
                        userLevel: _currentLevel,
                      );
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: AppColors.vibrantOrange),
            ),
          MessageInputBar(
            controller: _controller,
            isLoading: _isLoading,
            onSend: _sendMessage,
            onSubmitted: (_) => _sendMessage(),
          ),
        ],
      ),
    );
  }
}
