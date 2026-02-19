import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../widgets/chat/norwegian_audio_button.dart';

class AudioElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String textContent = element.textContent;
    final String href = element.attributes['href'] ?? '';

    if (href.startsWith('tts:')) {
      // IMPORTANT : On enlève "tts:" ET on décode les caractères spéciaux (%20, etc.)
      final String textToSpeak = Uri.decodeComponent(href.substring(4));

      return NorwegianAudioButton(text: textContent, audioText: textToSpeak);
    }

    return null;
  }
}
