import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets/chat/empty_chat.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/message_input_bar.dart';
import '../view_models/chat_view_model.dart';
import '../core/core.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late AppErrorHandler _errorHandler;

  @override
  void initState() {
    super.initState();
    _errorHandler = AppErrorHandler();
    
    // Initialiser le ViewModel après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ChatViewModel>();
      viewModel.initialize().catchError((e) {
        _errorHandler.handleError(e);
      });
    });
  }

  Future<void> _handleSendMessage(String text) async {
    final viewModel = context.read<ChatViewModel>();
    try {
      await viewModel.sendMessage(text);
    } catch (e) {
      if (mounted) {
        _errorHandler.handleError(e);
      }
    }
  }

  Future<void> _handleLogout() async {
    final viewModel = context.read<ChatViewModel>();
    try {
      await viewModel.logout();
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        _errorHandler.handleError(
          e,
          customMessage: 'Erreur lors de la déconnexion. Veuillez réessayer.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.deepBlue,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Hero(tag: 'app_logo', child: Image.asset('assets/Wolf.png')),
        ),
        title: Text(
          l10n.chatScreenTitle,
          style: const TextStyle(
            color: AppColors.deepBlue,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textDark),
            onPressed: () => context.push('/chat/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              Expanded(
                child: viewModel.messages.isEmpty
                    ? const EmptyChat()
                    : ListView.builder(
                        controller: viewModel.scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: viewModel.messages.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(
                            message: viewModel.messages[index],
                            onReply: (text) {
                              viewModel.messageController.text = text;
                            },
                            onSend: (text) {
                              viewModel.messageController.text = text;
                              _handleSendMessage(text);
                            },
                            userLevel: viewModel.currentLevel,
                          );
                        },
                      ),
              ),
              if (viewModel.isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(
                    color: AppColors.vibrantOrange,
                  ),
                ),
              MessageInputBar(
                controller: viewModel.messageController,
                isLoading: viewModel.isLoading,
                onSend: _handleSendMessage,
                onSubmitted: _handleSendMessage,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
