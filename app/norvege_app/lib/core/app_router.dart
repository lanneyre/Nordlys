/// AppRouter - Configuration du routing avec GoRouter
/// Centralise toutes les routes et la navigation
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth_gate.dart';
import '../screens/chat_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../core/service_locator.dart';

/// Routes disponibles dans l'app
abstract class AppRoutes {
  static const String auth = '/';
  static const String login = '/login';
  static const String chat = '/chat';
  static const String profile = '/profile';
}

/// Gestionnaire de routing typé
class AppRouter {
  static final AppRouter _instance = AppRouter._internal();

  factory AppRouter() => _instance;
  AppRouter._internal();

  late GoRouter _router;

  GoRouter get router => _router;

  /// Initialiser le router - à appeler dans main()
  void initialize() {
    _router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: AppRoutes.auth,
      redirect: _redirect,
      routes: _buildRoutes(),
      errorBuilder: (context, state) => _buildErrorPage(state),
    );
  }

  /// Redirection basée sur l'état d'authentification
  /// Cette fonction est appelée à chaque navigation
  String? _redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = ServiceLocator.authService.currentUser != null;
    final isLoggingIn = state.matchedLocation == AppRoutes.login;
    final isAuth = state.matchedLocation == AppRoutes.auth;

    // Si l'utilisateur se connecte ET qu'il est authentifié, aller au chat
    if (isAuthenticated && (isLoggingIn || isAuth)) {
      return AppRoutes.chat;
    }

    // Si l'utilisateur n'est pas authentifié ET qu'il n'est pas sur la page de login ou auth
    if (!isAuthenticated && !isLoggingIn && !isAuth) {
      return AppRoutes.auth;
    }

    return null;
  }

  /// Construire la liste des routes
  List<RouteBase> _buildRoutes() {
    return [
      // Route d'authentification (AuthGate)
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthGate(),
      ),
      // Route de login
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Route principale du chat
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
        routes: [
          // Route du profil (navigable depuis le chat)
          GoRoute(
            path: 'profile',
            name: 'chat-profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Route standalone du profil
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile-standalone',
        builder: (context, state) => const ProfileScreen(),
      ),
    ];
  }

  /// Page d'erreur
  Widget _buildErrorPage(GoRouterState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Page non trouvée'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _router.go(AppRoutes.chat),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigation vers une route
  void go(String location, {Object? extra}) {
    _router.go(location, extra: extra);
  }

  /// Navigation avec retour possible
  Future<dynamic> push(String location, {Object? extra}) {
    return _router.push(location, extra: extra);
  }

  /// Remplacer la route actuelle
  void replace(String location, {Object? extra}) {
    _router.replace(location, extra: extra);
  }

  /// Revenir à la page précédente
  void pop() {
    if (_router.canPop()) {
      _router.pop();
    }
  }

  /// Vérifier si on peut revenir
  bool canPop() => _router.canPop();
}
