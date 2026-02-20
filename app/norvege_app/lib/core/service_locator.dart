/// Service Locator pour l'injection de dépendances
/// Utilise GetIt pour centraliser toutes les instances de services

import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/ai_service.dart';
import '../services/tts_service.dart';

final getIt = GetIt.instance;

/// Fonction à appeler une seule fois dans main() pour initialiser tous les services
void setupServiceLocator() {
  // --- SERVICES SINGLETON ---
  // On s'assure qu'il n'y a qu'une seule instance de chaque service
  getIt.registerSingleton<AuthService>(
    AuthService(),
    signalsReady: false, // Marquer comme ready après Supabase init
  );

  getIt.registerSingleton<AiService>(AiService());

  getIt.registerSingleton<TtsService>(TtsService());

  // Signaler que les services sont prêts
  getIt.allReady();
}

/// Classe helper pour accéder facilement aux services
class ServiceLocator {
  static AuthService get authService => getIt<AuthService>();
  static AiService get aiService => getIt<AiService>();
  static TtsService get ttsService => getIt<TtsService>();
}
