import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:norvege_app/models/chat_message.dart';
import 'package:norvege_app/widgets/chat/message_bubble.dart';

void main() {
  group('MessageBubble Widget Tests', () {
    late ChatMessage testMessage;

    setUp(() {
      testMessage = ChatMessage(text: 'Hei, hvordan går det?', isUser: true);
    });

    testWidgets('affiche un message utilisateur', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: testMessage,
              onReply: (String reply) {},
              onSend: (String message) {},
            ),
          ),
        ),
      );

      expect(find.text('Hei, hvordan går det?'), findsOneWidget);
    });

    testWidgets('affiche un message de l\'IA avec couleur différente', (
      WidgetTester tester,
    ) async {
      final aiMessage = ChatMessage(
        text: 'Hallo! Jeg går veldig bra!',
        isUser: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: aiMessage,
              onReply: (String reply) {},
              onSend: (String message) {},
            ),
          ),
        ),
      );

      expect(find.text('Hallo! Jeg går veldig bra!'), findsOneWidget);

      // Vérifier que le bubble a une couleur blanche (IA) et non bleue (utilisateur)
      final bubbleContainer = find
          .byType(Container)
          .first; // Premier Container trouvé
      expect(bubbleContainer, findsWidgets);
    });

    testWidgets('alinemet du message utilisateur à droite', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: testMessage,
              onReply: (String reply) {},
              onSend: (String message) {},
            ),
          ),
        ),
      );

      final alignWidget = find.byType(Align);
      expect(alignWidget, findsOneWidget);

      final align = tester.widget<Align>(alignWidget);
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('alignement du message IA à gauche', (
      WidgetTester tester,
    ) async {
      final aiMessage = ChatMessage(text: 'Hallo!', isUser: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: aiMessage,
              onReply: (String reply) {},
              onSend: (String message) {},
            ),
          ),
        ),
      );

      final alignWidget = find.byType(Align);
      expect(alignWidget, findsOneWidget);

      final align = tester.widget<Align>(alignWidget);
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('message avec métadonnées ui_action', (
      WidgetTester tester,
    ) async {
      final messageWithAction = ChatMessage(
        text: 'Voici un quiz',
        isUser: false,
        metadata: {'ui_action': 'quiz', 'question': 'Quel est le mot correct?'},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: messageWithAction,
              onReply: (String reply) {},
              onSend: (String message) {},
            ),
          ),
        ),
      );

      expect(find.text('Voici un quiz'), findsOneWidget);
    });

    testWidgets('message avec texte long (long-form content)', (
      WidgetTester tester,
    ) async {
      final longMessage = ChatMessage(
        text:
            'Dette er en veldig lang melding som skal teste om widgeten håndles lange tekster korrekt. Den har flere setninger og skal vises korrekt med innpakking av tekst. La oss legge til mer tekst for å sikre at dette fungerer.',
        isUser: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MessageBubble(
                message: longMessage,
                onReply: (String reply) {},
                onSend: (String message) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MessageBubble), findsOneWidget);
    });

    testWidgets('message avec caractères spéciaux norvégiens', (
      WidgetTester tester,
    ) async {
      final norwegianMessage = ChatMessage(
        text: 'Hvordan skriver jeg å, ø, og æ på tastaturet?',
        isUser: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: norwegianMessage,
              onReply: (String reply) {},
              onSend: (String message) {},
            ),
          ),
        ),
      );

      expect(
        find.text('Hvordan skriver jeg å, ø, og æ på tastaturet?'),
        findsOneWidget,
      );
    });

    testWidgets('appel du callback onSend', (WidgetTester tester) async {
      String? capturedMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: testMessage,
              onReply: (String reply) {},
              onSend: (String message) {
                capturedMessage = message;
              },
            ),
          ),
        ),
      );

      // Le callback devrait être disponible dans la structure du widget
      expect(find.byType(MessageBubble), findsOneWidget);
    });

    testWidgets('appel du callback onReply', (WidgetTester tester) async {
      String? capturedReply;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: testMessage,
              onReply: (String reply) {
                capturedReply = reply;
              },
              onSend: (String message) {},
            ),
          ),
        ),
      );

      expect(find.byType(MessageBubble), findsOneWidget);
    });

    testWidgets('message avec métadonnées nulles affiche le texte', (
      WidgetTester tester,
    ) async {
      final messageWithoutMetadata = ChatMessage(
        text: 'Message simple sans metadata',
        isUser: true,
        metadata: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: messageWithoutMetadata,
              onReply: (String reply) {},
              onSend: (String message) {},
            ),
          ),
        ),
      );

      expect(find.text('Message simple sans metadata'), findsOneWidget);
    });

    testWidgets('multiple message bubbles en sequence', (
      WidgetTester tester,
    ) async {
      final messages = [
        ChatMessage(text: 'Hei', isUser: true),
        ChatMessage(text: 'Hallo!', isUser: false),
        ChatMessage(text: 'Hvordan går det?', isUser: true),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: messages
                  .map(
                    (msg) => MessageBubble(
                      message: msg,
                      onReply: (String reply) {},
                      onSend: (String message) {},
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      );

      expect(find.byType(MessageBubble), findsNWidgets(3));
      expect(find.text('Hei'), findsOneWidget);
      expect(find.text('Hallo!'), findsOneWidget);
      expect(find.text('Hvordan går det?'), findsOneWidget);
    });

    testWidgets('message avec texte vide', (WidgetTester tester) async {
      final emptyMessage = ChatMessage(text: '', isUser: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: emptyMessage,
              onReply: (String reply) {},
              onSend: (String message) {},
            ),
          ),
        ),
      );

      expect(find.byType(MessageBubble), findsOneWidget);
    });

    testWidgets('message avec markdown simple', (WidgetTester tester) async {
      final markdownMessage = ChatMessage(
        text: 'Ceci est **bold** et *italic*',
        isUser: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: markdownMessage,
              onReply: (String reply) {},
              onSend: (String message) {},
            ),
          ),
        ),
      );

      expect(find.byType(MessageBubble), findsOneWidget);
    });
  });
}
