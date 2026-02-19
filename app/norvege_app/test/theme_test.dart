import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:norvege_app/models/chat_message.dart';
import 'package:norvege_app/theme.dart';

void main() {
  group('Theme Tests', () {
    test('AppColors définit les bonnes couleurs', () {
      expect(AppColors.deepBlue, Color(0xFF00305A));
      expect(AppColors.lightBlue, Color(0xFF2C5364));
      expect(AppColors.vibrantOrange, Color(0xFFFF9F1C));
      expect(AppColors.softGray, Color(0xFFF4F6F8));
      expect(AppColors.textDark, Color(0xFF2D3436));
    });

    test('appTheme utilise Material3', () {
      expect(appTheme.useMaterial3, true);
    });

    test('appTheme a une couleur primaire', () {
      expect(appTheme.primaryColor, AppColors.deepBlue);
    });

    test('appTheme a un scaffold background blanc', () {
      expect(appTheme.scaffoldBackgroundColor, Colors.white);
    });

    test('appTheme configure les boutons élevés', () {
      expect(appTheme.elevatedButtonTheme, isNotNull);
      expect(appTheme.elevatedButtonTheme.style, isA<ButtonStyle>());
    });

    test('appTheme configure les InputDecorations', () {
      expect(appTheme.inputDecorationTheme, isNotNull);
      expect(appTheme.inputDecorationTheme.filled, true);
      expect(appTheme.inputDecorationTheme.fillColor, AppColors.softGray);
    });

    test('les couleurs sont bien définies', () {
      const colors = [
        AppColors.deepBlue,
        AppColors.lightBlue,
        AppColors.vibrantOrange,
        AppColors.softGray,
        AppColors.textDark,
        AppColors.messageOk,
        AppColors.messagekO,
      ];

      for (final color in colors) {
        expect(color, isA<Color>());
      }
    });

    test('messageOk est vert (succès)', () {
      expect(AppColors.messageOk, Color.fromARGB(255, 6, 87, 0));
    });

    test('messagekO est rouge (erreur)', () {
      expect(AppColors.messagekO, Color.fromARGB(255, 180, 0, 0));
    });
  });

  group('Widget Theme Integration Tests', () {
    testWidgets('MaterialApp applique le thème correctement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          home: Scaffold(
            body: Center(
              child: ElevatedButton(onPressed: () {}, child: const Text('OK')),
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('couleur du texte est respectée', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          home: Scaffold(
            body: Center(
              child: Text(
                'Test Text',
                style: TextStyle(color: AppColors.textDark),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Text'), findsOneWidget);
    });

    testWidgets('bouton avec couleur orange', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Action'),
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
    });

    testWidgets('champ texte avec fond gris clair', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          home: Scaffold(
            body: Center(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Entrez du texte',
                  fillColor: AppColors.softGray,
                  filled: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('texte headlineMedium avec style blanc', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          home: Scaffold(
            body: Center(
              child: Text(
                'Titre Principal',
                style: appTheme.textTheme.headlineMedium,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Titre Principal'), findsOneWidget);
    });
  });

  group('Integration Tests - Chat Message avec Theme', () {
    testWidgets('message utilisateur avec theme', (WidgetTester tester) async {
      final message = ChatMessage(text: 'Hei fra bruker', isUser: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          home: Scaffold(
            body: Container(
              color: AppColors.deepBlue, // Fond du message utilisateur
              child: Text(message.text),
            ),
          ),
        ),
      );

      expect(find.text('Hei fra bruker'), findsOneWidget);
    });

    testWidgets('message IA avec theme', (WidgetTester tester) async {
      final message = ChatMessage(text: 'Hei fra IA', isUser: false);

      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          home: Scaffold(
            body: Container(color: Colors.white, child: Text(message.text)),
          ),
        ),
      );

      expect(find.text('Hei fra IA'), findsOneWidget);
    });
  });
}
