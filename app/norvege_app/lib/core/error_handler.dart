/// Classe pour gérer les erreurs de manière cohérente
/// Traduit les exceptions en messages utilisateur lisibles

import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

class AppError {
  final String code;
  final String message;
  final dynamic originalError;

  AppError({required this.code, required this.message, this.originalError});
}

class ErrorHandler {
  /// Parse une erreur et retourne un message utilisateur
  static AppError handleError(dynamic error, [AppLocalizations? l10n]) {
    // --- SUPABASE AUTH ERRORS ---
    if (error is AuthException) {
      return _handleAuthError(error, l10n);
    }

    // --- SUPABASE STORAGE ERRORS ---
    if (error is StorageException) {
      return _handleStorageError(error, l10n);
    }

    // --- SUPABASE DATABASE ERRORS ---
    if (error is PostgrestException) {
      return _handleDatabaseError(error, l10n);
    }

    // --- GENERIC ERRORS ---
    return AppError(
      code: 'UNKNOWN_ERROR',
      message: error.toString(),
      originalError: error,
    );
  }

  static AppError _handleAuthError(
    AuthException error, [
    AppLocalizations? l10n,
  ]) {
    String message = error.message;

    if (error.message.contains('Invalid login credentials')) {
      message =
          l10n?.loginError('Email ou mot de passe incorrect') ??
          'Email ou mot de passe incorrect';
    } else if (error.message.contains('User already registered')) {
      message =
          l10n?.loginError('Cet email est déjà utilisé') ??
          'Cet email est déjà utilisé';
    } else if (error.message.contains('Email not confirmed')) {
      message =
          l10n?.loginError('Veuillez confirmer votre email') ??
          'Veuillez confirmer votre email';
    }

    return AppError(code: 'AUTH_ERROR', message: message, originalError: error);
  }

  static AppError _handleStorageError(
    StorageException error, [
    AppLocalizations? l10n,
  ]) {
    String message = error.message;

    if (error.message.contains('Bucket not found')) {
      message =
          l10n?.profileError('Erreur de stockage') ?? 'Erreur de stockage';
    } else if (error.message.contains('Object not found')) {
      message =
          l10n?.profileError('Fichier non trouvé') ?? 'Fichier non trouvé';
    } else if (error.message.contains('Payload too large')) {
      message =
          l10n?.profileError('Fichier trop volumineux') ??
          'Fichier trop volumineux';
    }

    return AppError(
      code: 'STORAGE_ERROR',
      message: message,
      originalError: error,
    );
  }

  static AppError _handleDatabaseError(
    PostgrestException error, [
    AppLocalizations? l10n,
  ]) {
    String message = error.message;

    if (error.code == '23505') {
      message =
          l10n?.profileError('Cet enregistrement existe déjà') ??
          'Cet enregistrement existe déjà';
    } else if (error.code == '23503') {
      message =
          l10n?.profileError('Référence invalide') ?? 'Référence invalide';
    } else if (error.code == '42P01') {
      message = l10n?.profileError('Table non trouvée') ?? 'Table non trouvée';
    }

    return AppError(
      code: 'DATABASE_ERROR_${error.code}',
      message: message,
      originalError: error,
    );
  }
}
