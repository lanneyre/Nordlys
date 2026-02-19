import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/chat_message.dart';
import '../../theme.dart';
import '../../utils/audio_element_builder.dart'; // Import du Builder
import 'quiz_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(String) onReply;
  final void Function(String) onSend;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onReply,
    required this.onSend,
  });

  String _processNorwegianTags(String rawText) {
    // Regex qui cherche tout ce qui est entre [[ et ]]
    final RegExp exp = RegExp(r'\[\[(.*?)\]\]');

    return rawText.replaceAllMapped(exp, (Match m) {
      final textContent = m[1] ?? "";

      // 1. On garde le texte tel quel pour l'affichage (entre crochets)
      // 2. On ENCODE le texte pour l'URL (entre parenthèses) pour éviter les erreurs d'espaces
      final encodedUrl = Uri.encodeComponent(textContent);

      return '[$textContent](tts:$encodedUrl)';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final uiAction = message.metadata?['ui_action'];
    final processedText = _processNorwegianTags(message.text);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.deepBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: processedText,
              selectable: true,
              // C'EST ICI QUE LA MAGIE OPÈRE ✨
              builders: {
                'a':
                    AudioElementBuilder(), // On branche notre builder sur les liens 'a'
              },
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: isUser ? Colors.white : AppColors.textDark,
                  fontSize: 16,
                  height: 1.4,
                ),
                tableBody: TextStyle(
                  color: isUser ? Colors.white : AppColors.textDark,
                ),
                tableHead: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBlue,
                ),
                tableBorder: TableBorder.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                strong: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUser ? Colors.white : AppColors.vibrantOrange,
                ),
              ),
            ),
            if (!isUser && uiAction != null) ...[
              const Divider(height: 20, color: AppColors.softGray),
              if (uiAction['type'] == 'input')
                _buildInlineInput(
                  context,
                  uiAction['placeholder'] ?? "Écrivez ici...",
                ),
              if (uiAction['type'] == 'choice')
                _buildInlineChoices(uiAction['options'] ?? []),
              if (uiAction['type'] == 'quiz')
                QuizMessage(
                  questions: uiAction['questions'] ?? [],
                  label: uiAction['label'] ?? "Envoyer",
                  onReply: (fullResponseText) {
                    onReply(fullResponseText);
                    onSend(fullResponseText);
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInlineInput(BuildContext context, String placeholder) {
    final TextEditingController inlineController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: inlineController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: placeholder,
                isDense: true,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  onReply(value);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.check_circle,
              color: AppColors.vibrantOrange,
              size: 32,
            ),
            onPressed: () {
              if (inlineController.text.trim().isNotEmpty) {
                onReply(inlineController.text);
                onSend(inlineController.text);
                FocusScope.of(context).unfocus();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInlineChoices(List<dynamic> options) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.deepBlue,
              elevation: 1,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.softGray),
              ),
            ),
            onPressed: () {
              onReply(option.toString());
              onSend(option.toString());
            },
            child: Text(
              option.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }
}
