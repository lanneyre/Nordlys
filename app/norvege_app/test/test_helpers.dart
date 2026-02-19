import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:norvege_app/models/chat_message.dart';

// Test Helpers et Utilities
class MockCallbackTracker {
  int callCount = 0;
  List<dynamic> capturedArgs = [];

  void trackCall(dynamic arg) {
    callCount++;
    capturedArgs.add(arg);
  }

  void reset() {
    callCount = 0;
    capturedArgs = [];
  }
}

// Widget Test Helpers
class TestChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onReply;
  final VoidCallback onSend;

  const TestChatBubble({
    super.key,
    required this.message,
    required this.onReply,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(message.text),
      ),
    );
  }
}

void main() {
  group('Test Helpers and Utilities', () {
    test('MockCallbackTracker enregistre les appels', () {
      final tracker = MockCallbackTracker();

      tracker.trackCall('test1');
      expect(tracker.callCount, 1);
      expect(tracker.capturedArgs.length, 1);

      tracker.trackCall('test2');
      expect(tracker.callCount, 2);
      expect(tracker.capturedArgs.length, 2);
    });

    test('MockCallbackTracker reset fonctionne', () {
      final tracker = MockCallbackTracker();

      tracker.trackCall('test');
      expect(tracker.callCount, 1);

      tracker.reset();
      expect(tracker.callCount, 0);
      expect(tracker.capturedArgs.length, 0);
    });

    test('MockCallbackTracker capture les arguments', () {
      final tracker = MockCallbackTracker();
      final testMessage = 'Hello World';

      tracker.trackCall(testMessage);

      expect(tracker.capturedArgs.first, 'Hello World');
    });
  });

  group('Test Widget Render Helpers', () {
    testWidgets('TestChatBubble rend un message utilisateur', (
      WidgetTester tester,
    ) async {
      final message = ChatMessage(text: 'Test', isUser: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestChatBubble(
              message: message,
              onReply: () {},
              onSend: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('TestChatBubble rend un message IA', (
      WidgetTester tester,
    ) async {
      final message = ChatMessage(text: 'Response', isUser: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestChatBubble(
              message: message,
              onReply: () {},
              onSend: () {},
            ),
          ),
        ),
      );

      expect(find.text('Response'), findsOneWidget);
    });
  });

  group('Assertion Helpers', () {
    test('vérification que les messages sont dans le bon ordre', () {
      final messages = [
        ChatMessage(text: 'Message 1', isUser: true),
        ChatMessage(text: 'Message 2', isUser: false),
        ChatMessage(text: 'Message 3', isUser: true),
      ];

      expect(messages[0].isUser, isTrue);
      expect(messages[1].isUser, isFalse);
      expect(messages[2].isUser, isTrue);
    });

    test('vérification des métadonnées complètes', () {
      final metadata = {
        'exercise_id': 'ex-001',
        'difficulty': 'A1',
        'score': 85,
        'timestamp': DateTime.now(),
      };

      expect(metadata, containsPair('exercise_id', 'ex-001'));
      expect(metadata, containsPair('difficulty', 'A1'));
      expect(metadata, containsPair('score', 85));
    });

    test('vérification d\'absence de métadonnées indésirables', () {
      final message = ChatMessage(text: 'Test', isUser: true, metadata: null);

      expect(message.metadata, isNull);
    });
  });

  group('Batch Test Assertions', () {
    test('tous les messages sont valides', () {
      final messages = [
        ChatMessage(text: 'Msg 1', isUser: true),
        ChatMessage(text: 'Msg 2', isUser: false),
        ChatMessage(text: 'Msg 3', isUser: true),
      ];

      for (final msg in messages) {
        expect(msg.text, isNotEmpty);
        expect(msg.isUser, isA<bool>());
      }
    });

    test('structure des métadonnées dans une liste de messages', () {
      final messages = [
        ChatMessage(text: 'Exercice 1', isUser: false, metadata: {'id': '1'}),
        ChatMessage(text: 'Exercice 2', isUser: false, metadata: {'id': '2'}),
      ];

      int metadataCount = messages.where((m) => m.metadata != null).length;
      expect(metadataCount, 2);
    });
  });

  group('Test Data Builders', () {
    test('créer un message avec des valeurs par défaut', () {
      final message = ChatMessage(text: 'Default', isUser: true);

      expect(message.text, 'Default');
      expect(message.isUser, isTrue);
      expect(message.metadata, isNull);
    });

    test('créer un message riche avec métadonnées', () {
      final richMessage = ChatMessage(
        text: 'Rich Content',
        isUser: false,
        metadata: {
          'type': 'lesson',
          'vocabulary': ['word1', 'word2'],
          'points': 100,
        },
      );

      expect(richMessage.metadata, isNotNull);
      expect(richMessage.metadata!['type'], 'lesson');
      expect(richMessage.metadata!['vocabulary'], isA<List>());
    });

    test('créer une conversation de test', () {
      List<ChatMessage> createTestConversation() {
        return [
          ChatMessage(text: 'Greet', isUser: true),
          ChatMessage(text: 'Hello', isUser: false),
          ChatMessage(text: 'How are you?', isUser: true),
          ChatMessage(text: 'Great!', isUser: false),
        ];
      }

      final conversation = createTestConversation();
      expect(conversation.length, 4);
      expect(conversation[0].isUser, isTrue);
      expect(conversation[1].isUser, isFalse);
    });
  });

  group('Test Matchers Extensions', () {
    test('matcher personnalisé pour ChatMessage', () {
      final message = ChatMessage(text: 'Test', isUser: true);

      // Vérifier le texte
      expect(
        message.text,
        allOf(isNotEmpty, contains('Test'), startsWith('T')),
      );
    });

    test('matcher pour métadonnées complexes', () {
      final message = ChatMessage(
        text: 'Complex',
        isUser: false,
        metadata: {
          'nested': {'deep': 'value'},
          'array': [1, 2, 3],
        },
      );

      expect(message.metadata, isA<Map>());
      expect(message.metadata!.keys.length, greaterThanOrEqualTo(1));
    });
  });

  group('Test Timing Helpers', () {
    test('mesure du temps de création de plusieurs messages', () async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        ChatMessage(text: 'Message $i', isUser: i % 2 == 0);
      }

      stopwatch.stop();

      // Les messages doivent être créés rapidement (< 100ms normalement)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('Test State Management Helpers', () {
    test('tracking des changements d\'état', () {
      final messages = <ChatMessage>[];

      messages.add(ChatMessage(text: 'Msg 1', isUser: true));
      expect(messages.length, 1);

      messages.add(ChatMessage(text: 'Msg 2', isUser: false));
      expect(messages.length, 2);

      messages.removeLast();
      expect(messages.length, 1);
    });

    test('validation de l\'ordre des messages', () {
      final messages = [
        ChatMessage(text: 'First', isUser: true),
        ChatMessage(text: 'Second', isUser: false),
        ChatMessage(text: 'Third', isUser: true),
      ];

      expect(messages[0].text, 'First');
      expect(messages[1].text, 'Second');
      expect(messages[2].text, 'Third');
    });
  });
}
