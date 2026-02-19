import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/app_logger.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPluginWorking = true;

  TtsService() {
    if (!kIsWeb && !Platform.isLinux) {
      // On initialise le plugin SEULEMENT si on n'est pas sur Linux
      _initPlugin();
    }
  }

  Future<void> _initPlugin() async {
    try {
      await _flutterTts.setLanguage("nb-NO");
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.setVolume(1.0);
    } catch (e) {
      AppLogger.error('Erreur plugin TTS: $e');
      _isPluginWorking = false;
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    // --- CAS SPÉCIAL LINUX (La méthode MacGyver) ---
    if (!kIsWeb && Platform.isLinux) {
      try {
        // On appelle directement le programme système
        // On utilise 'espeak-ng' (ou 'espeak' selon ce que vous avez)
        // '-v nb' demande la voix norvégienne
        await Process.run('espeak-ng', ['-v', 'nb', text]);
      } catch (e) {
        AppLogger.error('Erreur commande Linux: $e');
      }
      return; // On s'arrête là pour Linux
    }

    // --- CAS STANDARD (Android / iOS / Web) ---
    if (_isPluginWorking) {
      try {
        await _flutterTts.stop();
        await _flutterTts.speak(text);
      } catch (e) {
        AppLogger.error('Erreur lecture plugin: $e');
      }
    }
  }

  Future<void> stop() async {
    if (!kIsWeb && Platform.isLinux) {
      // Sur Linux, on peut tuer le processus (optionnel, souvent inutile pour des phrases courtes)
      // Process.run('pkill', ['espeak-ng']);
      return;
    }

    if (_isPluginWorking) {
      await _flutterTts.stop();
    }
  }
}
