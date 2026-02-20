/// Utilitaires de validation pour formulaires et données
/// Centralisé pour éviter la duplication de logique

import 'constants.dart';

class ValidationHelper {
  /// Valide un email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    if (!RegExp(RegexPatterns.email).hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  /// Valide un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Minimum ${AppConstants.minPasswordLength} caractères';
    }
    // Optionnel: valider la complexité
    if (!RegExp(RegexPatterns.password).hasMatch(value)) {
      return 'Doit contenir majuscules, minuscules, chiffres et caractères spéciaux';
    }
    return null;
  }

  /// Valide confirmation de mot de passe
  static String? validatePasswordConfirmation(
    String? password,
    String? confirm,
  ) {
    final passError = validatePassword(password);
    if (passError != null) return passError;

    if (confirm == null || confirm.isEmpty) {
      return 'Confirmez le mot de passe';
    }

    if (password != confirm) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  /// Valide un nom d'utilisateur
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nom requis';
    }
    if (value.length < AppConstants.minNameLength) {
      return 'Minimum ${AppConstants.minNameLength} caractères';
    }
    if (value.length > AppConstants.maxNameLength) {
      return 'Maximum ${AppConstants.maxNameLength} caractères';
    }
    return null;
  }

  /// Valide un objectif d'apprentissage
  static String? validateObjective(String? value) {
    if (value == null || value.isEmpty) {
      return 'Objectif requis';
    }
    if (value.length > AppConstants.maxObjectiveLength) {
      return 'Objectif trop long (max ${AppConstants.maxObjectiveLength} caractères)';
    }
    return null;
  }

  /// Valide qu'au moins un mode est sélectionné
  static String? validateModeSelection(List<String> modes) {
    if (modes.isEmpty) {
      return 'Sélectionnez au moins un style';
    }
    return null;
  }
}
