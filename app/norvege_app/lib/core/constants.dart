/// Fichier centralisé pour toutes les constantes de l'application
/// Permet une maintenance facile et une configurationglobale
library;

class AppConstants {
  // --- SUPABASE ---
  static const String supabaseBucketAvatars = 'avatars';
  static const String supabaseBucketLessons = 'lessons';

  // --- VALIDATION ---
  static const int minPasswordLength = 8;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxObjectiveLength = 500;

  // --- DELAYS & TIMEOUTS ---
  static final Duration apiTimeout = Duration(seconds: 30);
  static final Duration snackBarDuration = Duration(seconds: 4);
  static const int debounceDelayMs = 500;

  // --- IMAGES ---
  static const int imageQuality = 85;
  static const int maxImageSizeKB = 5000;

  // --- LEARNING MODES (localisés via AppLocalizations) ---
  // Ces listes sont initialisées dynamiquement dans les screens
  // Voir: LoginScreen.didChangeDependencies() et ProfileScreen.didChangeDependencies()

  // --- PAGINATION ---
  static const int messagesPageSize = 20;
  static const int lessonsPageSize = 10;

  // --- STOCKAGE LOCAL ---
  static const String prefKeyLanguage = 'app_language';
  static const String prefKeyTheme = 'app_theme';
  static const String prefKeyLastSync = 'last_sync_timestamp';

  // --- DATABASE TABLE NAMES ---
  static const String tableProfiles = 'profiles';
  static const String tableMessages = 'chat_messages';
  static const String tableLessons = 'lessons';
}

/// Classe pour les durées par défaut
class AppDurations {
  static final Duration animationFast = Duration(milliseconds: 200);
  static final Duration animationNormal = Duration(milliseconds: 300);
  static final Duration animationSlow = Duration(milliseconds: 500);
}

/// Classe pour les dimensions UI
class AppDimensions {
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 24.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double gapSmall = 8.0;
  static const double gapMedium = 16.0;
  static const double gapLarge = 24.0;
  static const double avatarRadiusDefault = 70.0;
}

/// Expressions régulières pour validation
class RegexPatterns {
  static const String email =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
  static const String password =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

  static const String username = r'^[a-zA-Z0-9_-]{2,50}$';
}
