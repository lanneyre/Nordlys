/// Providers centralisés pour toute l'application
/// Utilise Provider package pour un meilleur state management
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../core/service_locator.dart';
import '../view_models/chat_view_model.dart';
import '../view_models/login_view_model.dart';
import '../view_models/profile_view_model.dart';
import '../services/auth_service.dart';
import '../services/ai_service.dart';
import '../services/tts_service.dart';

// ============================================================================
// SERVICES PROVIDERS FACTORIES
// ============================================================================

/// Factory pour AuthService (singleton)
AuthService authServiceProvider() => ServiceLocator.authService;

/// Factory pour AiService (singleton)
AiService aiServiceProvider() => ServiceLocator.aiService;

/// Factory pour TtsService (singleton)
TtsService ttsServiceProvider() => ServiceLocator.ttsService;

// ============================================================================
// VIEWMODEL PROVIDERS FACTORIES
// ============================================================================

/// Factory pour ChatViewModel
ChatViewModel chatViewModelProvider() => ChatViewModel();

/// Factory pour LoginViewModel
LoginViewModel loginViewModelProvider() => LoginViewModel();

/// Factory pour ProfileViewModel
ProfileViewModel profileViewModelProvider() => ProfileViewModel();

// ============================================================================
// PROVIDER SETUP HELPERS
// ============================================================================

/// Liste complète des providers à enregistrer dans l'app
/// À utiliser dans MultiProvider dans main()
List<SingleChildWidget> getAppProviders() {
  return [
    // Services
    Provider<AuthService>(create: (_) => authServiceProvider()),
    Provider<AiService>(create: (_) => aiServiceProvider()),
    Provider<TtsService>(create: (_) => ttsServiceProvider()),
    
    // ViewModels - Utiliser Provider pour les ValueNotifier
    // Les widgets les utiliseront avec ValueListenableBuilder
    ChangeNotifierProvider<ChatViewModel>(
      create: (_) => chatViewModelProvider(),
    ),
    ChangeNotifierProvider<LoginViewModel>(
      create: (_) => loginViewModelProvider(),
    ),
    
    // ChangeNotifierProvider pour ProfileViewModel (qui étend ChangeNotifier)
    ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => profileViewModelProvider(),
    ),
  ];
}

// ============================================================================
// CONSUMER EXTENSIONS
// ============================================================================

/// Extension pour accéder facilement aux services dans les widgets
extension ProviderExtension on BuildContext {
  AuthService get authService => read<AuthService>();
  AiService get aiService => read<AiService>();
  TtsService get ttsService => read<TtsService>();
  ChatViewModel get chatViewModel => read<ChatViewModel>();
  LoginViewModel get loginViewModel => read<LoginViewModel>();
  ProfileViewModel get profileViewModel => read<ProfileViewModel>();
}
