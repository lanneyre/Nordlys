/// AppErrorHandler - Gestion centralisée des erreurs
/// Centralise toute la gestion d'erreurs et les logs pour une meilleure
/// maintenabilité et debugging en production
library;

import 'package:flutter/material.dart';
import '../utils/app_logger.dart';

/// Types d'erreurs applicatives
enum AppErrorType {
  authentication,
  authorization,
  network,
  validation,
  aiService,
  database,
  unknown,
}

/// Classe représentant une erreur applicative
class AppException implements Exception {
  final String message;
  final AppErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.type = AppErrorType.unknown,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Gestionnaire centralisé des erreurs
class AppErrorHandler {
  static final AppErrorHandler _instance = AppErrorHandler._internal();

  factory AppErrorHandler() => _instance;
  AppErrorHandler._internal();

  /// Callbacks pour afficher les erreurs dans l'UI
  Function(String message, {required AppErrorType type})? _errorCallback;
  Function()? _clearErrorCallback;

  /// Enregistrer les callbacks UI
  void registerErrorCallbacks({
    required Function(String message, {required AppErrorType type}) onError,
    required Function() onClear,
  }) {
    _errorCallback = onError;
    _clearErrorCallback = onClear;
  }

  /// Traiter une exception et l'afficher à l'utilisateur
  void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? customMessage,
  }) {
    // Log l'erreur complète pour le débogage
    AppLogger.error(
      'Erreur: $error',
      stackTrace ?? StackTrace.current,
    );

    // Déterminer le type d'erreur et le message à afficher
    final (message, type) = _parseError(error, customMessage: customMessage);

    // Afficher l'erreur à l'utilisateur via le callback
    _errorCallback?.call(message, type: type);
  }

  /// Parser une exception et retourner un message utilisateur-friendly
  (String, AppErrorType) _parseError(
    dynamic error, {
    String? customMessage,
  }) {
    if (customMessage != null) {
      return (customMessage, AppErrorType.unknown);
    }

    if (error is AppException) {
      return (error.message, error.type);
    }

    final errorStr = error.toString().toLowerCase();

    // Erreurs d'authentification
    if (errorStr.contains('auth') ||
        errorStr.contains('not connected') ||
        errorStr.contains('no session')) {
      return ('Erreur d\'authentification. Veuillez vous reconnecter.', AppErrorType.authentication);
    }

    // Erreurs de réseau
    if (errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('socket') ||
        errorStr.contains('timeout')) {
      return ('Erreur réseau. Vérifiez votre connexion Internet.', AppErrorType.network);
    }

    // Erreurs d'IA
    if (errorStr.contains('ai') || errorStr.contains('function') || errorStr.contains('edge')) {
      return ('Erreur du service IA. Veuillez réessayer.', AppErrorType.aiService);
    }

    // Erreurs de validation
    if (errorStr.contains('validation') || errorStr.contains('invalid')) {
      return ('Données invalides. Veuillez vérifier votre saisie.', AppErrorType.validation);
    }

    // Erreurs de base de données
    if (errorStr.contains('database') || errorStr.contains('query')) {
      return ('Erreur de base de données. Veuillez réessayer.', AppErrorType.database);
    }

    // Erreur par défaut
    return ('Une erreur est survenue. Veuillez réessayer.', AppErrorType.unknown);
  }

  /// Afficher une erreur via SnackBar dans le contexte Flutter
  static void showErrorSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    Color backgroundColor = const Color(0xFFE74C3C),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Afficher un message de succès via SnackBar
  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = const Color(0xFF27AE60),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Afficher un dialogue d'erreur
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Nettoyer les erreurs affichées
  void clearError() {
    _clearErrorCallback?.call();
  }
}

/// Extension pour faciliter l'utilisation sur les futures
extension FutureErrorHandling<T> on Future<T> {
  Future<T?> handleError(
    BuildContext context, {
    String? customMessage,
  }) async {
    try {
      return await this;
    } catch (e, stackTrace) {
      if (context.mounted) {
        AppErrorHandler().handleError(
          e,
          stackTrace: stackTrace,
          customMessage: customMessage,
        );
      }
      return null;
    }
  }
}
