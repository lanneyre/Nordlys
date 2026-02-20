import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets/chat/empty_chat.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/message_input_bar.dart';
import 'profile_screen.dart';
import '../view_models/chat_view_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel();
    _viewModel.initialize();
  }

  Future<void> _handleSendMessage(String text) async {
    try {
      await _viewModel.sendMessage(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.chatGenericError(e.toString()),
            ),
            backgroundColor: AppColors.messagekO,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _viewModel.logout();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: $e'),
            backgroundColor: AppColors.messagekO,
          ),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: ValueListenableBuilder<Object?>(
        valueListenable: _viewModel,
        // ignore: unnecessary_underscores
        builder: (context, _, __) {
          return Column(
            children: [
              Expanded(
                child: _viewModel.messages.isEmpty
                    ? const EmptyChat()
                    : ListView.builder(
                        controller: _viewModel.scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _viewModel.messages.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(
                            message: _viewModel.messages[index],
                            onReply: (text) {
                              _viewModel.messageController.text = text;
                            },
                            onSend: (text) {
                              _viewModel.messageController.text = text;
                              _handleSendMessage(text);
                            },
                            userLevel: _viewModel.currentLevel,
                          );
                        },
                      ),
              ),
              if (_viewModel.isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(
                    color: AppColors.vibrantOrange,
                  ),
                ),
              MessageInputBar(
                controller: _viewModel.messageController,
                isLoading: _viewModel.isLoading,
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
    _viewModel.dispose();
    super.dispose();
  }
}
