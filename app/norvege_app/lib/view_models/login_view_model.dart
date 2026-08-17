/// ViewModel pour LoginScreen
/// Sépare la logique d'authentification de l'UI
/// Facilite les tests unitaires
library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/service_locator.dart';
import '../utils/app_logger.dart';

class LoginViewModel extends ValueNotifier<Object?> {
  LoginViewModel() : super(null);
  // --- STATE ---
  bool isLoading = false;
  bool isLogin = true;
  List<String> selectedModes = [];
  String selectedLevel = '';

  // --- CONTROLLERS ---
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final objectiveController = TextEditingController();

  // --- DONNÉES LOCALES ---
  final _authService = ServiceLocator.authService;

  // --- GETTERS ---
  bool get canSubmit {
    if (isLogin) {
      return emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    } else {
      return emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty &&
          nameController.text.isNotEmpty &&
          objectiveController.text.isNotEmpty &&
          selectedModes.isNotEmpty;
    }
  }

  /// Mettre à jour le niveau sélectionné
  void updateSelectedLevel(String level) {
    selectedLevel = level;
    notifyListeners();
  }

  /// Basculer entre mode login/signup ou ajouter/retirer un mode d'apprentissage
  void toggleMode([String? mode]) {
    if (mode == null) {
      // Basculer entre login et signup
      isLogin = !isLogin;
      clearFields();
    } else {
      // Ajouter/retirer un mode d'apprentissage
      if (selectedModes.contains(mode)) {
        // Empêcher de désélectionner si c'est le seul
        if (selectedModes.length > 1) {
          selectedModes.remove(mode);
        }
      } else {
        selectedModes.add(mode);
      }
    }
    notifyListeners();
  }

  /// Se connecter (SignIn)
  Future<void> signIn() async {
    if (!canSubmit) {
      throw Exception('Email et mot de passe requis');
    }

    try {
      isLoading = true;
      notifyListeners();

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      await _authService.signIn(email, password);

      isLoading = false;
      notifyListeners();
      AppLogger.success('Connexion réussie');
    } catch (e) {
      isLoading = false;
      notifyListeners();
      AppLogger.error('Erreur de connexion: $e');
      rethrow;
    }
  }

  /// S'inscrire (SignUp)
  Future<void> signUp() async {
    if (!canSubmit) {
      throw Exception('Tous les champs sont obligatoires');
    }

    try {
      isLoading = true;
      notifyListeners();

      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();
      final name = nameController.text.trim();
      final objective = objectiveController.text.trim();

      // Validations
      if (password != confirmPassword) {
        throw AuthException('Les mots de passe ne correspondent pas');
      }
      if (password.length < 6) {
        throw AuthException(
          'Le mot de passe doit contenir au moins 6 caractères',
        );
      }
      if (selectedModes.isEmpty) {
        throw AuthException(
          'Veuillez choisir au moins un style d\'apprentissage',
        );
      }

      await _authService.signUp(
        email: email,
        password: password,
        displayName: name,
        objective: objective,
        startingLevel: selectedLevel,
        learningMode: selectedModes.join(','),
      );

      isLoading = false;
      notifyListeners();
      AppLogger.success('Inscription réussie');
    } catch (e) {
      isLoading = false;
      notifyListeners();
      AppLogger.error('Erreur d\'inscription: $e');
      rethrow;
    }
  }

  /// Soumettre le formulaire (login ou signup)
  Future<void> submit() async {
    try {
      if (isLogin) {
        await signIn();
      } else {
        await signUp();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Nettoyer les champs de texte
  void clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    objectiveController.clear();
  }

  /// Réinitialiser le ViewModel
  void reset() {
    isLoading = false;
    isLogin = true;
    selectedModes = [];
    selectedLevel = '';
    clearFields();
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    objectiveController.dispose();
    super.dispose();
  }
}
