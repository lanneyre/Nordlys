import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';

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
  bool _hasError = false;
  Uint8List? _imageBytes;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateImage();
  }

  Future<void> _generateImage() async {
    try {
      // 1. Flutter demande gentiment à Supabase (qui va contourner Cloudflare)
      final response = await Supabase.instance.client.functions.invoke(
        'generate-image',
        body: {'imagePrompt': widget.imagePrompt},
      );

      if (response.status == 200 && response.data != null) {
        final String? base64Str = response.data['image_base64'];

        if (base64Str != null) {
          if (mounted) {
            setState(() {
              // 2. On transforme le texte reçu en vraie image
              _imageBytes = base64Decode(base64Str);
              _isLoading = false;
            });
          }
          return;
        }
      }
      throw Exception("L'image n'est pas arrivée.");
    } catch (e) {
      debugPrint("🚨 ERREUR SUPABASE/IMAGE : $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: _buildImageContent(l10n),
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

  Widget _buildImageContent(AppLocalizations l10n) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.vibrantOrange),
            const SizedBox(height: 16),
            Text(
              l10n.chatImageGenerating,
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
            l10n.chatImageGenerationError,
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_imageBytes != null) {
      // Magique : Flutter sait dessiner du Base64 sans faire de requête HTTP !
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
