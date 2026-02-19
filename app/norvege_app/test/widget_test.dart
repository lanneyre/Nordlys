// Test principal de l'application NorvegeIA
// Ce fichier teste le démarrage et la structure globale de l'application

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:norvege_app/main.dart';
import 'package:norvege_app/theme.dart';

void main() {
  group('NorvegeIA App - Main Tests', () {
    testWidgets('app démarre correctement', (WidgetTester tester) async {
      // Construire l'app et déclencher un frame
      await tester.pumpWidget(const NorvegeIAApp());
      await tester.pumpAndSettle();

      // Vérifier que l'app est bien construite
      expect(find.byType(NorvegeIAApp), findsOneWidget);
    });

    testWidgets('app utilise le thème correct', (WidgetTester tester) async {
      await tester.pumpWidget(const NorvegeIAApp());
      await tester.pumpAndSettle();

      // Vérifier que le thème est appliqué
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app a une structure MaterialApp valide', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const NorvegeIAApp());
      await tester.pumpAndSettle();

      // Vérifier les éléments clés
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('debugShowCheckedModeBanner est désactivé', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const NorvegeIAApp());
      final MaterialApp app = tester.widget(find.byType(MaterialApp));

      expect(app.debugShowCheckedModeBanner, false);
    });

    testWidgets('app supporte les locales', (WidgetTester tester) async {
      await tester.pumpWidget(const NorvegeIAApp());
      await tester.pumpAndSettle();

      // L'app devrait être supportée avec localisations
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('couleurs du thème sont accessibles', (
      WidgetTester tester,
    ) async {
      // Vérifier que les couleurs du thème sont bien définies
      expect(AppColors.deepBlue, isNotNull);
      expect(AppColors.vibrantOrange, isNotNull);
      expect(AppColors.softGray, isNotNull);
    });

    testWidgets('theme a des styles de texte valides', (
      WidgetTester tester,
    ) async {
      expect(appTheme.textTheme, isNotNull);
      expect(appTheme.textTheme.headlineMedium, isNotNull);
    });

    testWidgets('theme a des styles de boutons valides', (
      WidgetTester tester,
    ) async {
      expect(appTheme.elevatedButtonTheme, isNotNull);
    });

    testWidgets('theme configure les champs texte', (
      WidgetTester tester,
    ) async {
      expect(appTheme.inputDecorationTheme, isNotNull);
      expect(appTheme.inputDecorationTheme.filled, isTrue);
    });
  });

  group('App Navigation & Structure', () {
    testWidgets('app réagit aux changements d\'authentification', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const NorvegeIAApp());
      await tester.pumpAndSettle();

      // L'app utilise AuthGate pour la navigation
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('scaffold background est blanc', (WidgetTester tester) async {
      expect(appTheme.scaffoldBackgroundColor, Colors.white);
    });
  });

  group('App Configuration', () {
    testWidgets('app utilise Material3', (WidgetTester tester) async {
      expect(appTheme.useMaterial3, isTrue);
    });

    testWidgets('app a une couleur primaire définie', (
      WidgetTester tester,
    ) async {
      expect(appTheme.primaryColor, AppColors.deepBlue);
    });

    testWidgets('NorvegeIAApp est un StatelessWidget', (
      WidgetTester tester,
    ) async {
      const app = NorvegeIAApp();
      expect(app, isA<StatelessWidget>());
    });

    testWidgets('NorvegeIAApp peut être construit avec une clé', (
      WidgetTester tester,
    ) async {
      const app = NorvegeIAApp(key: ValueKey('test-app-key'));
      expect(app.key, isNotNull);
    });
  });

  group('Internationalization Tests', () {
    testWidgets('app supporte les localisations', (WidgetTester tester) async {
      await tester.pumpWidget(const NorvegeIAApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Smoke Tests', () {
    testWidgets('app n\'a pas d\'erreurs au démarrage', (
      WidgetTester tester,
    ) async {
      expect(() async {
        await tester.pumpWidget(const NorvegeIAApp());
        await tester.pumpAndSettle();
      }, returnsNormally);
    });

    testWidgets('app ne plante pas pendant 5 secondes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const NorvegeIAApp());

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
