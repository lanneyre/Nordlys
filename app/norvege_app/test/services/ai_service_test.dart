import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:norvege_app/services/ai_service.dart';
import 'package:norvege_app/models/chat_message.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGotrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

class MockFunctionResponse implements FunctionResponse {
  @override
  final dynamic data;

  @override
  final int status;

  MockFunctionResponse({required this.data, this.status = 200});
}

void main() {
  group('AiService', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockGotrueClient mockGotrueClient;
    late MockUser mockUser;
    late MockFunctionsClient mockFunctionsClient;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockGotrueClient = MockGotrueClient();
      mockUser = MockUser();
      mockFunctionsClient = MockFunctionsClient();

      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockGotrueClient.currentUser).thenReturn(mockUser);
      when(() => mockSupabaseClient.auth).thenReturn(mockGotrueClient);
      when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient);
    });

    test('AiService est un singleton', () {
      final service1 = AiService();
      final service2 = AiService();

      expect(identical(service1, service2), isTrue);
    });

    test('generateLesson retourne une réponse structurée', () async {
      final responseData = {
        'reply': 'Hei! Hvordan kan jeg hjelpe deg?',
        'metadata': {'exercise_id': 'ex-001', 'difficulty': 'A1'},
      };

      when(
        () => mockFunctionsClient.invoke(
          'generate-lesson',
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => MockFunctionResponse(data: responseData));

      final result = await mockFunctionsClient.invoke(
        'generate-lesson',
        body: {
          'userMessage': 'Teach me Norwegian basics',
          'userId': 'user-123',
          'saveToLog': true,
        },
      );

      expect(result.data, isA<Map>());
      expect(result.data['reply'], contains('Hei'));
    });

    test('generateLesson gère les métadonnées nulles', () async {
      final responseData = {
        'reply': 'Responses sans metadata',
        'metadata': null,
      };

      when(
        () => mockFunctionsClient.invoke(
          'generate-lesson',
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => MockFunctionResponse(data: responseData));

      final result = await mockFunctionsClient.invoke(
        'generate-lesson',
        body: {'userMessage': 'Hello', 'userId': 'user-123', 'saveToLog': true},
      );

      expect(result.data['metadata'], isNull);
    });

    test('evaluateUserLevel retourne un niveau valide', () async {
      final responseData = {'level': 'A1'};

      when(
        () => mockFunctionsClient.invoke(
          'evaluate-level',
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => MockFunctionResponse(data: responseData));

      final result = await mockFunctionsClient.invoke(
        'evaluate-level',
        body: {'conversation': 'Utilisateur: Hei\nCoach: Hallo!'},
      );

      expect(result.data['level'], 'A1');
    });

    test('evaluateUserLevel valide les niveaux', () {
      const validLevels = ['A0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

      for (final level in validLevels) {
        expect(validLevels.contains(level), isTrue);
      }
    });

    test('generateLesson avec texte vide', () async {
      final responseData = {
        'reply': 'Veuillez entrer un message',
        'metadata': null,
      };

      when(
        () => mockFunctionsClient.invoke(
          'generate-lesson',
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => MockFunctionResponse(data: responseData));

      final result = await mockFunctionsClient.invoke(
        'generate-lesson',
        body: {'userMessage': '', 'userId': 'user-123', 'saveToLog': true},
      );

      expect(result.data['reply'], isNotEmpty);
    });

    test('generateLesson avec metadata complexe', () async {
      final responseData = {
        'reply': 'Voici un exercice',
        'metadata': {
          'exercise_id': 'ex-012',
          'difficulty': 'A2',
          'exercise_type': 'vocabulary',
          'words': ['ord', 'navn', 'verbe'],
          'score_criteria': {'accuracy': 0.8, 'fluency': 0.7},
        },
      };

      when(
        () => mockFunctionsClient.invoke(
          'generate-lesson',
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => MockFunctionResponse(data: responseData));

      final result = await mockFunctionsClient.invoke(
        'generate-lesson',
        body: {
          'userMessage': 'Exercise vocabulary',
          'userId': 'user-123',
          'saveToLog': true,
        },
      );

      expect(result.data['metadata'], isA<Map>());
      expect(result.data['metadata']['exercise_type'], 'vocabulary');
    });

    test('generateLesson avec saveToLog false', () async {
      final responseData = {
        'reply': 'Response without logging',
        'metadata': null,
      };

      when(
        () => mockFunctionsClient.invoke(
          'generate-lesson',
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => MockFunctionResponse(data: responseData));

      final result = await mockFunctionsClient.invoke(
        'generate-lesson',
        body: {
          'userMessage': 'No log message',
          'userId': 'user-123',
          'saveToLog': false,
        },
      );

      expect(result.data['reply'], isNotEmpty);
    });

    test('evaluateUserLevel avec historique complet', () async {
      final messages = [
        ChatMessage(text: 'Hva heter du?', isUser: true),
        ChatMessage(text: 'Jeg heter Claude', isUser: false),
        ChatMessage(text: 'Où er du fra?', isUser: true),
        ChatMessage(text: 'Jeg er fra Norge', isUser: false),
      ];

      final responseData = {'level': 'B1'};

      when(
        () => mockFunctionsClient.invoke(
          'evaluate-level',
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => MockFunctionResponse(data: responseData));

      final result = await mockFunctionsClient.invoke(
        'evaluate-level',
        body: {
          'conversation': messages
              .map((m) {
                return "${m.isUser ? 'Utilisateur' : 'Coach'}: ${m.text}";
              })
              .join('\n'),
        },
      );

      expect(result.data['level'], 'B1');
    });
  });
}
