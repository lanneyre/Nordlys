import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';

class ImageDescriptionMessage extends StatefulWidget {
  final String imagePrompt;
  final String placeholder;
  final String? imageData; // Nouveau paramètre qui reçoit le Base64
  final Function(String) onReply;
  final Function(String) onSend;

  const ImageDescriptionMessage({
    super.key,
    required this.imagePrompt,
    required this.placeholder,
    this.imageData,
    required this.onReply,
    required this.onSend,
  });

  @override
  State<ImageDescriptionMessage> createState() =>
      _ImageDescriptionMessageState();
}

class _ImageDescriptionMessageState extends State<ImageDescriptionMessage> {
  final TextEditingController _controller = TextEditingController();

  /// Nettoie et décode la chaîne Base64 envoyée par FastAPI
  Uint8List? _getDecodedImage() {
    if (widget.imageData == null) return null;
    try {
      // Le backend envoie souvent sous le format "data:image/jpeg;base64,ZmFrZ..."
      final parts = widget.imageData!.split(',');
      final cleanBase64 = parts.length > 1 ? parts[1] : parts[0];
      return base64Decode(cleanBase64);
    } catch (e) {
      debugPrint("Erreur de décodage de l'image : $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _getDecodedImage();

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- ZONE DE L'IMAGE ---
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 200),
              decoration: BoxDecoration(color: Colors.grey[200]),
              child: imageBytes != null
                  ? Image.memory(imageBytes, fit: BoxFit.cover)
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          // --- ZONE DE TEXTE ---
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
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
                    if (value.trim().isNotEmpty) widget.onReply(value);
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
                  if (_controller.text.trim().isNotEmpty) {
                    widget.onReply(_controller.text);
                    widget.onSend(_controller.text);
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
