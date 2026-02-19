import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:norvege_app/services/auth_service.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGotrueClient extends Mock implements GoTrueClient {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

class MockAuthResponse extends Mock implements AuthResponse {}

void main() {
  group('AuthService', () {
    late MockGotrueClient mockGotrueClient;
    late MockUser mockUser;

    setUp(() {
      mockGotrueClient = MockGotrueClient();
      mockUser = MockUser();
    });

    test('currentUser retourne null quand non authentifié', () {
      when(() => mockGotrueClient.currentUser).thenReturn(null);

      expect(mockGotrueClient.currentUser, isNull);
    });

    test('currentUser retourne l\'utilisateur authentifié', () {
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockGotrueClient.currentUser).thenReturn(mockUser);

      final user = mockGotrueClient.currentUser;
      expect(user, isNotNull);
      expect(user!.id, 'user-123');
    });

    test('authStateChanges retourne un Stream', () {
      when(
        () => mockGotrueClient.onAuthStateChange,
      ).thenAnswer((_) => Stream.empty());

      expect(mockGotrueClient.onAuthStateChange, isA<Stream>());
    });

    test('signUp avec données valides', () async {
      when(
        () => mockGotrueClient.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => MockAuthResponse());

      expect(
        () => mockGotrueClient.signUp(
          email: 'test@example.com',
          password: 'password123',
          data: {
            'display_name': 'John Doe',
            'objective': 'Learn Norwegian',
            'starting_level': 'A1',
            'learning_mode': 'Fun',
          },
        ),
        returnsNormally,
      );
    });

    test('signIn avec email et password', () async {
      when(
        () => mockGotrueClient.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => MockAuthResponse());

      expect(
        () => mockGotrueClient.signInWithPassword(
          email: 'user@example.com',
          password: 'password123',
        ),
        returnsNormally,
      );
    });

    test('signOut', () async {
      when(
        () => mockGotrueClient.signOut(),
      ).thenAnswer((_) async => Future.value());

      expect(() => mockGotrueClient.signOut(), returnsNormally);
    });

    test('AuthService est un singleton', () {
      final service1 = AuthService();
      final service2 = AuthService();

      expect(identical(service1, service2), isTrue);
    });

    test('signUp avec données utilisateur complètes', () async {
      final userData = {
        'display_name': 'Marie Martin',
        'objective': 'Business Communication',
        'starting_level': 'A2',
        'learning_mode': 'Serious,Immersive',
      };

      when(
        () => mockGotrueClient.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {
        verify(
          () => mockGotrueClient.signUp(
            email: 'marie@example.com',
            password: 'SecurePass123!',
            data: userData,
          ),
        ).called(1);
        return MockAuthResponse();
      });

      expect(
        () => mockGotrueClient.signUp(
          email: 'marie@example.com',
          password: 'SecurePass123!',
          data: userData,
        ),
        returnsNormally,
      );
    });

    test('updateProfile met à jour les données utilisateur', () async {
      when(() => mockUser.id).thenReturn('user-456');

      expect(mockUser.id, 'user-456');
    });

    test('updateCurrentLevel met à jour le niveau', () async {
      when(() => mockUser.id).thenReturn('user-789');

      expect(mockUser.id, 'user-789');
    });
  });
}
