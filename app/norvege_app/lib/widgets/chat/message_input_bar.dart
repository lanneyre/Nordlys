import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:norvege_app/theme.dart';

class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Function(String) onSend;
  final Function(String) onSubmitted;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l10n.chatTypeHere,
                filled: true,
                fillColor: AppColors.softGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: AppColors.vibrantOrange,
            elevation: 0,
            onPressed: isLoading ? null : () => onSend(controller.text),
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
