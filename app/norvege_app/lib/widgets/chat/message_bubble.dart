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
  final String? userLevel;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onReply,
    required this.onSend,
    this.userLevel,
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
          color: AppColors.softGray,
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
                  color: AppColors.textDark,
                  fontSize: 16,
                  height: 1.4,
                ),
                tableBody: TextStyle(color: AppColors.textDark),
                tableHead: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBlue,
                ),
                tableBorder: TableBorder.all(
                  color: AppColors.softGray,
                  width: 1,
                ),
                strong: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUser ? AppColors.softGray : AppColors.vibrantOrange,
                ),
              ),
            ),
            if (!isUser && uiAction != null) ...[
              const Divider(height: 20, color: AppColors.softGray),
              // Special handling: Comprehension orale
              if (uiAction['type'] == 'input' &&
                  (uiAction['task'] == 'transcription' ||
                      uiAction['task'] == 'summary' ||
                      uiAction['audio_text'] != null ||
                      uiAction['audio_reference'] != null)) ...[
                _buildComprehensionWidget(context, uiAction),
                _buildInlineInput(
                  context,
                  uiAction['placeholder'] ?? "Écrivez ici...",
                ),
              ],

              // Special handling: Debate with min level
              if (uiAction['type'] == 'input' &&
                  (uiAction['debate'] != null || uiAction['min_level'] != null))
                _buildDebateWidget(context, uiAction),

              // Default handlers
              if (uiAction['type'] == 'input' &&
                  uiAction['debate'] == null &&
                  uiAction['task'] == null &&
                  uiAction['audio_text'] == null &&
                  uiAction['audio_reference'] == null)
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

  Widget _buildComprehensionWidget(BuildContext context, Map uiAction) {
    final String? audioRef =
        uiAction['audio_reference'] ?? uiAction['audio_text'];
    final String task = (uiAction['task'] ?? 'ecoute').toString();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compréhension orale — tâche: $task',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (audioRef != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transcription de référence disponible.'),
                const SizedBox(height: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.deepBlue,
                  ),
                  onPressed: () {
                    // Place la transcription dans la zone de saisie pour que l'utilisateur puisse l'éditer
                    onReply(audioRef);
                  },
                  child: const Text(
                    'Ouvrir la transcription dans le champ de saisie',
                  ),
                ),
              ],
            ),
          if (audioRef == null)
            Text('Écoute le passage et transcris ou résume selon la consigne.'),
        ],
      ),
    );
  }

  Widget _buildDebateWidget(BuildContext context, Map uiAction) {
    final String minLevel =
        (uiAction['min_level'] ?? uiAction['debate']?['min_level'] ?? 'B1')
            .toString();
    final bool allowed = _isLevelAtLeast(userLevel, minLevel);

    if (!allowed) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Le débat nécessite le niveau $minLevel. Votre niveau actuel: ${userLevel ?? 'inconnu'}.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Je propose une version guidée (discussion pas à pas) à la place.',
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final suggestion = 'Je choisis la version guidée du débat.';
                onReply(suggestion);
                onSend(suggestion);
              },
              child: const Text('Continuer avec la version guidée'),
            ),
          ],
        ),
      );
    }

    // Si autorisé, on laisse l'utilisateur répondre normalement (input builder sera affiché)
    return const SizedBox.shrink();
  }

  bool _isLevelAtLeast(String? userLevel, String requiredLevel) {
    if (userLevel == null) return false;
    final order = ['A0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    int idxUser = order.indexWhere(
      (e) => userLevel.toUpperCase().startsWith(e),
    );
    int idxReq = order.indexWhere(
      (e) => requiredLevel.toUpperCase().startsWith(e),
    );
    if (idxUser == -1 || idxReq == -1) return false;
    return idxUser >= idxReq;
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
