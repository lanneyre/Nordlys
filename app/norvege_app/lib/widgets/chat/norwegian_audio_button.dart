import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../core/service_locator.dart';  // ✅ Utilise ServiceLocator

class NorwegianAudioButton extends StatefulWidget {
  final String text;
  final String
  audioText; // Le texte à lire (parfois différent de celui affiché)

  const NorwegianAudioButton({
    super.key,
    required this.text,
    required this.audioText,
  });

  @override
  State<NorwegianAudioButton> createState() => _NorwegianAudioButtonState();
}

class _NorwegianAudioButtonState extends State<NorwegianAudioButton> {
  late final _ttsService = ServiceLocator.ttsService;  // ✅ Utilise ServiceLocator
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() => _isPlaying = true);
        await _ttsService.speak(widget.audioText);
        // Petite astuce : on attend un peu pour simuler la fin ou on utilise un listener du TTS
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) setState(() => _isPlaying = false);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isPlaying
              ? AppColors.vibrantOrange
              : AppColors.vibrantOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.vibrantOrange),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Prend juste la place nécessaire
          crossAxisAlignment: CrossAxisAlignment
              .center, // Garde le haut-parleur centré avec le texte
          children: [
            // --- C'EST ICI QUE LA MAGIE OPÈRE ---
            Flexible(
              child: Text(
                widget.text,
                style: TextStyle(
                  color: _isPlaying ? Colors.white : AppColors.vibrantOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  height:
                      1.3, // Un peu d'espacement entre les lignes si le texte s'enroule
                ),
                softWrap: true, // Autorise explicitement le retour à la ligne
              ),
            ),
            // -----------------------------------
            const SizedBox(width: 6),
            Icon(
              _isPlaying ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
              size: 18,
              color: _isPlaying ? Colors.white : AppColors.vibrantOrange,
            ),
          ],
        ),
      ),
    );
  }
}
