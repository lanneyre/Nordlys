import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:norvege_app/models/chat_message.dart';
import 'package:norvege_app/theme.dart';

/// Suite d'intégration complète pour tester les interactions entre composants
void main() {
  group('Integration Tests - Conversation Flow', () {
    test('création d\'une conversation complète', () {
      // 1. Utilisateur envoie un message
      final userMessage = ChatMessage(
        text: 'Hei, jeg vil lære norsk',
        isUser: true,
      );

      // 2. IA répond avec métadonnées
      final aiResponse = ChatMessage(
        text: 'Fantastisk! La oss begynne med noen grunnleggende ord.',
        isUser: false,
        metadata: {
          'exercise_id': 'lesson-001',
          'words': ['hei', 'jeg', 'vil', 'lære', 'norsk'],
        },
      );

      // 3. Utilisateur répond au quiz
      final userAnswer = ChatMessage(text: 'Ja', isUser: true);

      // 4. IA évalue la réponse
      final evaluation = ChatMessage(
        text: 'Très bien! Continue comme ça.',
        isUser: false,
        metadata: {'score': 0.95, 'next_level': 'A1'},
      );

      // Vérification
      expect(userMessage.isUser, isTrue);
      expect(aiResponse.isUser, isFalse);
      expect(userAnswer.isUser, isTrue);
      expect(evaluation.isUser, isFalse);
      expect(aiResponse.metadata!['exercise_id'], 'lesson-001');
      expect(evaluation.metadata!['score'], 0.95);
    });

    test('historique de conversation avec métadonnées progressives', () {
      final conversation = [
        ChatMessage(text: 'Hei', isUser: true),
        ChatMessage(
          text: 'Hallo!',
          isUser: false,
          metadata: {'difficulty': 'A0'},
        ),
        ChatMessage(text: 'Hvordan heter du?', isUser: true),
        ChatMessage(
          text: 'Jeg heter Claude',
          isUser: false,
          metadata: {'difficulty': 'A1', 'grammar_focus': 'verb_to_be'},
        ),
        ChatMessage(text: 'Hvor er du fra?', isUser: true),
        ChatMessage(
          text: 'Jeg er fra Norge',
          isUser: false,
          metadata: {
            'difficulty': 'A1',
            'grammar_focus': 'prepositions',
            'score': 85,
          },
        ),
      ];

      // Vérification
      expect(conversation.length, 6);
      expect(conversation[0].isUser, isTrue);
      expect(conversation[1].isUser, isFalse);

      // Vérifier la progression des difficultés
      final firstAI = conversation[1].metadata!['difficulty'];
      final secondAI = conversation[3].metadata!['difficulty'];
      final thirdAI = conversation[5].metadata!['difficulty'];

      expect(firstAI, 'A0');
      expect(secondAI, 'A1');
      expect(thirdAI, 'A1');
    });

    test('structure de quiz dans une conversation', () {
      final quizMessage = ChatMessage(
        text: 'Quel est le mot correct pour "bonjour"?',
        isUser: false,
        metadata: {
          'ui_action': 'quiz',
          'question': 'Choisissez la bonne réponse',
          'options': ['Hallo', 'Hei', 'Hallo igjen'],
          'correct_answer': 'Hei',
        },
      );

      // Utilisateur répond au quiz
      final userAnswer = ChatMessage(
        text: 'Hei',
        isUser: true,
        metadata: {'quiz_response': true, 'quiz_exercise_id': 'quiz-001'},
      );

      // IA évalue la réponse
      final feedback = ChatMessage(
        text: 'Correct! "Hei" est la bonne réponse pour dire bonjour.',
        isUser: false,
        metadata: {
          'is_correct': true,
          'points_earned': 10,
          'explanation': 'Hei is the informal way to greet in Norwegian',
        },
      );

      expect(quizMessage.metadata!['ui_action'], 'quiz');
      expect(userAnswer.metadata!['quiz_response'], isTrue);
      expect(feedback.metadata!['is_correct'], isTrue);
      expect(feedback.metadata!['points_earned'], 10);
    });

    test('conversation avec audio annotations', () {
      final messageWithAudio = ChatMessage(
        text: 'La prononciation correcte est: [[Hallo]]',
        isUser: false,
        metadata: {'audio_available': true, 'language': 'Norwegian'},
      );

      expect(messageWithAudio.text, contains('[[Hallo]]'));
      expect(messageWithAudio.metadata!['audio_available'], isTrue);
    });

    test('profil utilisateur dans les métadonnées', () {
      final systemMessage = ChatMessage(
        text: 'Profil mis à jour',
        isUser: false,
        metadata: {
          'user_profile': {
            'username': 'marieMartine',
            'current_level': 'A2',
            'target_level': 'B1',
            'total_points': 850,
            'avatar_url': 'https://example.com/avatar.png',
          },
          'learning_mode': 'Fun,Serious',
          'streak_days': 15,
        },
      );

      expect(systemMessage.metadata!['user_profile']['current_level'], 'A2');
      expect(systemMessage.metadata!['learning_mode'], contains('Fun'));
      expect(systemMessage.metadata!['streak_days'], 15);
    });

    test('exercice structuré avec progression', () {
      final lessons = [
        ChatMessage(
          text: 'Leçon 1: Salutations basiques',
          isUser: false,
          metadata: {
            'lesson_id': 'lesson-001',
            'level': 'A0',
            'progress': 0,
            'vocabulary': ['Hei', 'Hallo'],
          },
        ),
        ChatMessage(
          text: 'Leçon 2: Verbes basiques',
          isUser: false,
          metadata: {
            'lesson_id': 'lesson-002',
            'level': 'A1',
            'progress': 50,
            'vocabulary': ['er', 'heter', 'er fra'],
          },
        ),
        ChatMessage(
          text: 'Leçon 3: Prépositions',
          isUser: false,
          metadata: {
            'lesson_id': 'lesson-003',
            'level': 'A1',
            'progress': 100,
            'vocabulary': ['fra', 'i', 'på'],
          },
        ),
      ];

      // Vérifier la progression
      expect(lessons[0].metadata!['progress'], 0);
      expect(lessons[1].metadata!['progress'], 50);
      expect(lessons[2].metadata!['progress'], 100);

      // Vérifier les vocabulaires
      expect(lessons[0].metadata!['vocabulary'], containsAll(['Hei', 'Hallo']));
    });
  });

  group('Integration Tests - Theme Application', () {
    test('couleurs sont cohérentes dans l\'application', () {
      expect(AppColors.deepBlue, Color(0xFF00305A));
      expect(AppColors.vibrantOrange, Color(0xFFFF9F1C));

      // Messages utilisateur = bleu profond
      // Messages IA = blanc
      // Actions = orange vibrant
    });

    test('palette de couleurs pour états d\'alerte', () {
      expect(AppColors.messageOk, Color.fromARGB(255, 6, 87, 0));
      expect(AppColors.messagekO, Color.fromARGB(255, 180, 0, 0));
    });
  });

  group('Integration Tests - Error Handling', () {
    test('gestion des messages d\'erreur structurés', () {
      final errorMessage = ChatMessage(
        text: 'Une erreur est survenue. Veuillez réessayer.',
        isUser: false,
        metadata: {
          'error': true,
          'error_code': 'NETWORK_ERROR',
          'error_type': 'temporary',
          'retry_possible': true,
        },
      );

      expect(errorMessage.metadata!['error'], isTrue);
      expect(errorMessage.metadata!['error_code'], 'NETWORK_ERROR');
      expect(errorMessage.metadata!['retry_possible'], isTrue);
    });

    test('gestion des messages d\'avertissement', () {
      final warningMessage = ChatMessage(
        text: 'Attention: Votre session expire bientôt',
        isUser: false,
        metadata: {
          'warning': true,
          'warning_type': 'session_expiry',
          'action_required': true,
        },
      );

      expect(warningMessage.metadata!['warning'], isTrue);
      expect(warningMessage.metadata!['action_required'], isTrue);
    });
  });

  group('Integration Tests - User Progress Tracking', () {
    test('suivi de la progression utilisateur', () {
      final progressMessages = [
        ChatMessage(
          text: 'Jour 1 complété',
          isUser: false,
          metadata: {'day': 1, 'exercises_completed': 3, 'points_earned': 25},
        ),
        ChatMessage(
          text: 'Jour 2 complété',
          isUser: false,
          metadata: {'day': 2, 'exercises_completed': 5, 'points_earned': 45},
        ),
        ChatMessage(
          text: 'Jour 3 complété',
          isUser: false,
          metadata: {'day': 3, 'exercises_completed': 4, 'points_earned': 35},
        ),
      ];

      // Vérifier la progression
      int totalPoints = 0;
      int totalExercises = 0;

      for (final msg in progressMessages) {
        totalPoints += msg.metadata!['points_earned'] as int;
        totalExercises += msg.metadata!['exercises_completed'] as int;
      }

      expect(totalPoints, 105);
      expect(totalExercises, 12);
    });
  });

  group('Integration Tests - Data Validation', () {
    test('validation de l\'intégrité des métadonnées', () {
      final metadataTypes = {
        'string': 'value',
        'number': 123,
        'boolean': true,
        'list': [1, 2, 3],
        'map': {'nested': 'value'},
      };

      for (final entry in metadataTypes.entries) {
        final message = ChatMessage(
          text: 'Test',
          isUser: false,
          metadata: {entry.key: entry.value},
        );

        expect(message.metadata!.containsKey(entry.key), isTrue);
      }
    });

    test('caractères spéciaux dans les messages', () {
      final specialCharsMessage = ChatMessage(
        text: 'Test: @#\$%^&*()_+-=[]{}|;:\'",.<>?/~`',
        isUser: true,
      );

      expect(specialCharsMessage.text, isNotEmpty);
      expect(specialCharsMessage.text.length, greaterThan(0));
    });
  });
}
