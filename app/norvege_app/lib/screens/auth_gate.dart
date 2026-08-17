import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../core/service_locator.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: ServiceLocator.authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        // Redirect basé sur l'état de connexion
        if (session != null) {
          // Rediriger vers le chat après la connexion
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/chat');
          });
        } else {
          // Rediriger vers le login si déconnecté
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
