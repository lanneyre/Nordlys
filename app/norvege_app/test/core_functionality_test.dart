import 'package:flutter_test/flutter_test.dart';
import 'package:norvege_app/models/chat_message.dart';
import 'package:norvege_app/env.dart';

void main() {
  group('Environment Configuration Tests', () {
    test('Supabase URL is configured', () {
      expect(Env.supabaseUrl, isNotEmpty);
      expect(Env.supabaseUrl, startsWith('https://'));
    });

    test('Supabase Anon Key is configured', () {
      expect(Env.supabaseAnonKey, isNotEmpty);
      expect(Env.supabaseAnonKey.length, greaterThan(10));
    });

    test('Supabase URL points to correct domain', () {
      expect(Env.supabaseUrl, contains('supabase.co'));
    });
  });

  group('Data Flow Tests', () {
    test('message flow: user -> ai -> user', () {
      // 1. User sends a message
      final userMsg = ChatMessage(text: 'Teach me Norwegian', isUser: true);
      expect(userMsg.isUser, isTrue);

      // 2. AI processes and responds
      final aiMsg = ChatMessage(
        text: 'Let\'s start with basic greetings',
        isUser: false,
        metadata: {
          'lesson_id': 'lesson-001',
          'vocabulary': ['Hei', 'Hallo', 'Hallo igjen'],
        },
      );
      expect(aiMsg.isUser, isFalse);
      expect(aiMsg.metadata, isNotNull);

      // 3. User replies to lesson
      final userReply = ChatMessage(
        text: 'Hei',
        isUser: true,
        metadata: {'exercise_response': true},
      );
      expect(userReply.metadata!['exercise_response'], isTrue);

      // Verify flow
      expect(userMsg.isUser, isTrue);
      expect(aiMsg.isUser, isFalse);
      expect(userReply.isUser, isTrue);
    });
  });

  group('Application State Tests', () {
    test('conversation history is properly structured', () {
      final history = [
        ChatMessage(text: 'Hei', isUser: true),
        ChatMessage(text: 'Hallo!', isUser: false),
        ChatMessage(text: 'Hvordan går det?', isUser: true),
        ChatMessage(text: 'Bra, takk!', isUser: false),
      ];

      // Verify LIFO structure (last message is most recent)
      expect(history.last.text, 'Bra, takk!');

      // Verify alternating user/AI pattern
      for (int i = 0; i < history.length; i++) {
        final isEvenIndex = i % 2 == 0;

        if (isEvenIndex) {
          expect(history[i].isUser, isTrue);
        } else {
          expect(history[i].isUser, isFalse);
        }
      }
    });

    test('user profile data persistence', () {
      final userProfile = {
        'id': 'user-001',
        'email': 'user@example.com',
        'username': 'john_doe',
        'current_level': 'A1',
        'target_level': 'B1',
        'total_points': 500,
        'streak_days': 7,
        'learning_modes': ['Fun', 'Serious'],
      };

      // Verify all profile fields
      expect(userProfile['id'], 'user-001');
      expect(userProfile['current_level'], 'A1');
      expect(userProfile['total_points'], 500);
      expect(userProfile['learning_modes'], isA<List>());
    });

    test('lesson metadata structure', () {
      final lesson = {
        'id': 'lesson-001',
        'title': 'Basic Greetings',
        'level': 'A0',
        'duration_minutes': 10,
        'vocabulary': ['Hei', 'Hallo', 'Takk'],
        'grammar_focus': ['Basic pronouns'],
        'exercises_count': 5,
        'completed': false,
        'points_possible': 50,
      };

      expect(lesson['level'], 'A0');
      expect(lesson['vocabulary'], contains('Hei'));
      expect(lesson['exercises_count'], 5);
      expect(lesson['completed'], isFalse);
    });
  });

  group('Message Validation Tests', () {
    test('chat message properties validation', () {
      final msg = ChatMessage(
        text: 'Test message',
        isUser: true,
        metadata: {'test': true},
      );

      // Properties must be non-null or have defaults
      expect(msg.text, isNotNull);
      expect(msg.isUser, isNotNull);
      expect(msg.metadata, isNotNull);
    });

    test('metadata optional property', () {
      final msgWithMetadata = ChatMessage(
        text: 'With metadata',
        isUser: true,
        metadata: {'key': 'value'},
      );

      final msgWithoutMetadata = ChatMessage(
        text: 'Without metadata',
        isUser: false,
      );

      expect(msgWithMetadata.metadata, isNotNull);
      expect(msgWithoutMetadata.metadata, isNull);
    });
  });

  group('API Response Parsing Tests', () {
    test('parse generate-lesson response', () {
      final response = {
        'reply': 'Hei! La oss begynne.',
        'metadata': {
          'exercise_id': 'ex-001',
          'difficulty': 'A1',
          'words': ['hei', 'la', 'oss', 'begynne'],
        },
      };

      final msg = ChatMessage(
        text: response['reply'] as String,
        isUser: false,
        metadata: response['metadata'] as Map<String, dynamic>?,
      );

      expect(msg.text, 'Hei! La oss begynne.');
      expect(msg.metadata!['exercise_id'], 'ex-001');
    });

    test('parse evaluate-level response', () {
      final response = {'level': 'A2', 'confidence': 0.85};

      expect(response['level'], 'A2');
      expect(response['confidence'], 0.85);
    });
  });

  group('Search and Filter Tests', () {
    test('filter messages by user/ai', () {
      final messages = [
        ChatMessage(text: 'Msg 1', isUser: true),
        ChatMessage(text: 'Msg 2', isUser: false),
        ChatMessage(text: 'Msg 3', isUser: true),
        ChatMessage(text: 'Msg 4', isUser: false),
      ];

      final userMessages = messages.where((m) => m.isUser).toList();
      final aiMessages = messages.where((m) => !m.isUser).toList();

      expect(userMessages.length, 2);
      expect(aiMessages.length, 2);
    });

    test('search messages by text content', () {
      final messages = [
        ChatMessage(text: 'Hei, hvordan går det?', isUser: true),
        ChatMessage(text: 'Hallo! Fint, takk', isUser: false),
        ChatMessage(text: 'Hva heter du?', isUser: true),
      ];

      final searchResults = messages
          .where((m) => m.text.toLowerCase().contains('hei'))
          .toList();

      expect(searchResults.length, 2);
    });
  });

  group('Performance Tests', () {
    test('create large message list', () {
      final stopwatch = Stopwatch()..start();

      final messages = List<ChatMessage>.generate(
        1000,
        (index) => ChatMessage(
          text: 'Message $index',
          isUser: index % 2 == 0,
          metadata: index % 10 == 0
              ? {'id': index, 'timestamp': DateTime.now()}
              : null,
        ),
      );

      stopwatch.stop();

      expect(messages.length, 1000);
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000), // Should be fast
      );
    });

    test('search large message list', () {
      final messages = List<ChatMessage>.generate(
        500,
        (index) => ChatMessage(
          text: 'Message $index with content',
          isUser: index % 2 == 0,
        ),
      );

      final stopwatch = Stopwatch()..start();

      final results = messages
          .where((m) => m.text.contains('Message 100'))
          .toList();

      stopwatch.stop();

      expect(results, isNotEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });
  });
}
