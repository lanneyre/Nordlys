import 'package:flutter/foundation.dart';

/// Classe de logging centralisée pour l'application
class AppLogger {
  static const String _prefix = '🔵';

  /// Active/désactive le logging (utile pour la production)
  static bool _enableLogging = kDebugMode;

  /// Configure si le logging doit être actif
  static void setLoggingEnabled(bool enabled) {
    _enableLogging = enabled;
  }

  /// Log un message d'information
  static void info(String message) {
    if (_enableLogging) {
      debugPrint('$_prefix [INFO] $message');
    }
  }

  /// Log un message de succès ✅
  static void success(String message) {
    if (_enableLogging) {
      debugPrint('✅ [SUCCESS] $message');
    }
  }

  /// Log un message d'erreur ❌
  static void error(String message, [StackTrace? stackTrace]) {
    if (_enableLogging) {
      debugPrint('❌ [ERROR] $message');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Log un message d'avertissement ⚠️
  static void warning(String message) {
    if (_enableLogging) {
      debugPrint('⚠️ [WARNING] $message');
    }
  }

  /// Log un message de débogage 🐛
  static void debug(String message) {
    if (_enableLogging) {
      debugPrint('🐛 [DEBUG] $message');
    }
  }

  /// Log silencieuse - enregistre dans un service si nécessaire (futur)
  static void silent(String message) {
    // À l'avenir, envoyer à Crashlytics, Sentry, etc.
    debugPrint('🕵️ [SILENT] $message');
  }
}
