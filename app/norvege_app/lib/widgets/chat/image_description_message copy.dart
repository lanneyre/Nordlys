import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart'; // <-- L'import du dictionnaire

class ImageDescriptionMessage extends StatefulWidget {
  final String imagePrompt;
  final String placeholder;
  final Function(String) onReply;
  final Function(String) onSend;

  const ImageDescriptionMessage({
    super.key,
    required this.imagePrompt,
    required this.placeholder,
    required this.onReply,
    required this.onSend,
  });

  @override
  State<ImageDescriptionMessage> createState() =>
      _ImageDescriptionMessageState();
}

class _ImageDescriptionMessageState extends State<ImageDescriptionMessage> {
  bool _isLoading = true;
  bool _hasError = false; // <-- On utilise un flag au lieu du texte en dur
  Uint8List? _imageBytes;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateImage();
  }

  Future<void> _generateImage() async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'generate-image',
        body: {'imagePrompt': widget.imagePrompt},
      );

      if (response.status == 200 && response.data != null) {
        final String? base64Str = response.data['image_base64'];

        if (base64Str != null) {
          if (mounted) {
            setState(() {
              _imageBytes = base64Decode(base64Str);
              _isLoading = false;
            });
          }
          return;
        }
      }
      throw Exception("Pas d'image dans la réponse.");
    } catch (e) {
      print("🚨 ERREUR API IMAGE : $e"); // <-- Ajoutez cette ligne !
      if (mounted) {
        setState(() {
          _hasError = true; // On lève juste le drapeau d'erreur
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // On récupère le dictionnaire ici !
    final l10n = AppLocalizations.of(context)!;

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
              child: _buildImageContent(
                l10n,
              ), // On passe le dictionnaire à la méthode
            ),
          ),

          const SizedBox(height: 12),

          // --- ZONE DE TEXTE (Input) ---
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
                    if (value.trim().isNotEmpty) {
                      widget.onReply(value);
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

  // La méthode qui dessine l'intérieur du cadre
  Widget _buildImageContent(AppLocalizations l10n) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.vibrantOrange),
            const SizedBox(height: 16),
            Text(
              l10n.chatImageGenerating, // <-- Traduit !
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.chatImageGenerationError, // <-- Traduit !
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_imageBytes != null) {
      return Image.memory(_imageBytes!, fit: BoxFit.cover);
    }

    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
