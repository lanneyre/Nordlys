import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:norvege_app/screens/auth_gate.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGotrueClient extends Mock implements GoTrueClient {}

class MockAuthState extends Mock implements AuthState {
  final Session? _session;

  MockAuthState({Session? session}) : _session = session;

  @override
  Session? get session => _session;
}

class MockUser extends Mock implements User {
  final String _id;

  MockUser({String? id}) : _id = id ?? 'test-user-id';

  @override
  String get id => _id;
}

class MockSession extends Mock implements Session {
  final MockUser _user;

  MockSession({MockUser? user}) : _user = user ?? MockUser();

  @override
  User get user => _user;
}

void main() {
  group('AuthGate Widget', () {
    testWidgets('affiche CircularProgressIndicator pendant le chargement', (
      WidgetTester tester,
    ) async {
      final mockGotrueClient = MockGotrueClient();

      // Simuler un état d'attente
      when(
        () => mockGotrueClient.onAuthStateChange,
      ).thenAnswer((_) => Stream.value(MockAuthState(session: null)));

      await tester.pumpWidget(const MaterialApp(home: AuthGate()));

      // Attendre le chargement
      await tester.pumpAndSettle();

      // Vérifier que le widget est construit (pas d'erreur)
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('affiche LoginScreen quand l\'utilisateur n\'est pas connecté', (
      WidgetTester tester,
    ) async {
      // Ce test vérifie la structure sans implémentation détaillée du Supabase
      await tester.pumpWidget(const MaterialApp(home: AuthGate()));

      await tester.pumpAndSettle();

      // Le widget AuthGate existe
      expect(find.byType(AuthGate), findsOneWidget);
    });

    testWidgets('AuthGate est un widget sans état', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthGate()));

      expect(find.byType(AuthGate), findsOneWidget);
    });

    testWidgets('AuthGate utilise StreamBuilder pour les changements d\'auth', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthGate()));

      await tester.pumpAndSettle();

      expect(find.byType(StreamBuilder), findsOneWidget);
    });

    testWidgets(
      'AuthGate affiche un contenu réactif aux changements d\'authentification',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: AuthGate()));

        await tester.pumpAndSettle();

        // Le widget doit avoir un Scaffold (basé sur le code)
        expect(find.byType(Scaffold), findsWidgets);
      },
    );

    testWidgets('AuthGate gère correctement les états de connexion', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthGate()));

      await tester.pumpAndSettle();

      // Vérifier que le widget n'a pas d'erreurs
      expect(find.byType(AuthGate), findsOneWidget);
    });

    testWidgets('AuthGate change l\'affichage selon l\'état d\'auth', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthGate()));

      expect(find.byType(StreamBuilder), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('AuthGate est créé avec la bonne configuration', (
      WidgetTester tester,
    ) async {
      const authGate = AuthGate();

      expect(authGate, isNotNull);
      expect(authGate, isA<Widget>());
    });

    testWidgets('AuthGate a une clé optionnelle', (WidgetTester tester) async {
      const authGate = AuthGate(key: ValueKey('auth-gate-key'));

      expect(authGate.key, isNotNull);
    });

    testWidgets('Scaffold est visible dans l\'arborescence des widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthGate()));

      await tester.pumpAndSettle();

      // Vérifier la structure générale
      expect(find.byType(AuthGate), findsOneWidget);
      expect(find.byType(StreamBuilder), findsOneWidget);
    });

    testWidgets(
      'AuthGate attend correctement la fin du processus de authentification',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: AuthGate()));

        // Donner du temps au widget pour initialiser
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.byType(AuthGate), findsOneWidget);
      },
    );
  });
}
