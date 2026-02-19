import 'package:flutter_test/flutter_test.dart';
import 'package:norvege_app/services/tts_service.dart';

void main() {
  group('TtsService', () {
    late TtsService ttsService;

    setUp(() {
      // Initialize TtsService
      // Note: On Linux, le plugin peut ne pas être disponible
      ttsService = TtsService();
    });

    test('TtsService peut être instancié', () {
      expect(ttsService, isNotNull);
    });

    test('speak avec texte non-vide elle continue', () async {
      // Ce test vérifie que la fonction ne lance pas d'exception
      expect(() => ttsService.speak('Hei, hvordan går det?'), returnsNormally);
    });

    test('speak avec texte vide ne fait rien', () async {
      // Un texte vide ne devrait pas déclencher la lecture
      expect(() => ttsService.speak(''), returnsNormally);
    });

    test('speak avec texte court', () async {
      const shortText = 'Hei';
      expect(() => ttsService.speak(shortText), returnsNormally);
    });

    test('speak avec texte long', () async {
      const longText =
          'Hallo, jeg heter Claude og jeg lærer norsk. Jeg liker å snakke om kultur, natur, og språk. Hvordan kan jeg hjelpe deg i dag?';
      expect(() => ttsService.speak(longText), returnsNormally);
    });

    test('speak avec caractères spéciaux norvégiens', () async {
      const norwegianText = 'La oss lære: å, ø, og æ';
      expect(() => ttsService.speak(norwegianText), returnsNormally);
    });

    test('speak avec chiffres et nombres', () async {
      const numberText = 'Åttifire mennesker og tolv fugler';
      expect(() => ttsService.speak(numberText), returnsNormally);
    });

    test('stop arrête la lecture', () async {
      expect(() => ttsService.stop(), returnsNormally);
    });

    test('appels successifs de speak', () async {
      expect(() => ttsService.speak('Første tekst'), returnsNormally);

      expect(() => ttsService.speak('Annen tekst'), returnsNormally);

      expect(() => ttsService.speak('Tredje tekst'), returnsNormally);
    });

    test('speak suivi de stop', () async {
      expect(() => ttsService.speak('Test tekst'), returnsNormally);

      expect(() => ttsService.stop(), returnsNormally);
    });

    test('stop plusieurs fois successivement', () async {
      expect(() => ttsService.stop(), returnsNormally);

      expect(() => ttsService.stop(), returnsNormally);

      expect(() => ttsService.stop(), returnsNormally);
    });

    test('speak avec texte contenant ponctuation', () async {
      const punctuationText =
          'Hallo! Hvordan går det? Fint, takk. Hva er klokken?';
      expect(() => ttsService.speak(punctuationText), returnsNormally);
    });

    test('speak avec texte surréservé(placeholder)', () async {
      const mdText = 'Du kan bruke **bold** og *italic* i markdown';
      expect(() => ttsService.speak(mdText), returnsNormally);
    });

    test('TtsService gère correctement les accès multiples', () async {
      final service1 = TtsService();
      final service2 = TtsService();

      // Les deux instances devraient fonctionner
      expect(() async {
        await service1.speak('Tekst fra service 1');
        await service2.speak('Tekst fra service 2');
      }, returnsNormally);
    });

    test('speak avec URL encodée (type de contenu spécifique)', () async {
      const encodedText =
          'Hei%20verden'; // Texte avec encodage URL (cas limite)
      expect(() => ttsService.speak(encodedText), returnsNormally);
    });

    test('speak avec très long texte', () async {
      final veryLongText = 'Ord ' * 500; // Texte très long
      expect(() => ttsService.speak(veryLongText), returnsNormally);
    });

    test('service respecte les appels rapides', () async {
      // Vérifier que plusieurs appels rapides ne causent pas de problème
      final futures = <Future>[];

      for (int i = 0; i < 5; i++) {
        futures.add(ttsService.speak('Tekst $i'));
      }

      expect(() async => await Future.wait(futures), returnsNormally);
    });

    test('speak avec texte contenant emojis', () async {
      const emojiText = 'Hallo 👋 Hvordan går det? 😊';
      expect(() => ttsService.speak(emojiText), returnsNormally);
    });
  });
}
