import 'package:flutter_test/flutter_test.dart';
import 'package:norvege_app/models/chat_message.dart';

void main() {
  group('ChatMessage', () {
    test('création d\'un message utilisateur', () {
      final message = ChatMessage(text: 'Hei, hvordan går det?', isUser: true);

      expect(message.text, 'Hei, hvordan går det?');
      expect(message.isUser, isTrue);
      expect(message.metadata, isNull);
    });

    test('création d\'un message de l\'IA', () {
      final message = ChatMessage(text: 'Det går bra!', isUser: false);

      expect(message.text, 'Det går bra!');
      expect(message.isUser, isFalse);
      expect(message.metadata, isNull);
    });

    test('création d\'un message avec métadonnées', () {
      final metadata = {
        'exercise_id': '12345',
        'difficulty': 'A1',
        'word_count': 5,
      };

      final message = ChatMessage(
        text: 'Velkommen!',
        isUser: false,
        metadata: metadata,
      );

      expect(message.metadata, isNotNull);
      expect(message.metadata!['exercise_id'], '12345');
      expect(message.metadata!['difficulty'], 'A1');
      expect(message.metadata!['word_count'], 5);
    });

    test('message avec métadonnées ui_action', () {
      final metadata = {'ui_action': 'quiz', 'question': 'Traduis ce mot'};

      final message = ChatMessage(
        text: 'Quiz time!',
        isUser: false,
        metadata: metadata,
      );

      expect(message.metadata!['ui_action'], 'quiz');
      expect(message.metadata!['question'], 'Traduis ce mot');
    });

    test('deux messages identiques sont comparables', () {
      final message1 = ChatMessage(text: 'Test', isUser: true);

      final message2 = ChatMessage(text: 'Test', isUser: true);

      expect(message1.text, equals(message2.text));
      expect(message1.isUser, equals(message2.isUser));
    });

    test('message avec texte vide', () {
      final message = ChatMessage(text: '', isUser: true);

      expect(message.text, isEmpty);
      expect(message.isUser, isTrue);
    });

    test('message avec caractères spéciaux norvégiens', () {
      final text = 'Hei! Hva er det med å, ø, og æ?';
      final message = ChatMessage(text: text, isUser: true);

      expect(message.text, text);
      expect(message.text, contains('å'));
      expect(message.text, contains('ø'));
      expect(message.text, contains('æ'));
    });

    test('message avec métadonnées complexes', () {
      final complexMetadata = {
        'exercises': [
          {'id': '1', 'completed': true},
          {'id': '2', 'completed': false},
        ],
        'scores': {'vocabulary': 85, 'grammar': 72},
        'level_info': {'current': 'A1', 'progress': 65},
      };

      final message = ChatMessage(
        text: 'Voici vos progrès',
        isUser: false,
        metadata: complexMetadata,
      );

      expect(message.metadata!['exercises'], isA<List>());
      expect(message.metadata!['scores'], isA<Map>());
      expect(message.metadata!['level_info']['current'], 'A1');
    });
  });
}
