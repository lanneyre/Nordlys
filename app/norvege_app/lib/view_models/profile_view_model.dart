/// ViewModel pour ProfileScreen
/// Sépare la logique métier de la UI
/// Facilite les tests unitaires
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../core/service_locator.dart';
import '../utils/app_logger.dart';

class ProfileViewModel extends ChangeNotifier {
  // --- STATE ---
  String username = '';
  String targetLevel = '';
  String? currentAvatarUrl;
  File? selectedAvatarFile;
  bool hasUnsavedChanges = false;
  bool isLoading = true;
  List<String> selectedModes = [];

  // --- DONNÉES LOCALES ---
  final _authService = ServiceLocator.authService;

  // --- GETTERS ---
  bool get canSave =>
      username.isNotEmpty && targetLevel.isNotEmpty && selectedModes.isNotEmpty;

  String? get currentLevel => null;

  /// Charger le profil utilisateur depuis Supabase
  Future<void> loadProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      final data = await _authService.getProfile();

      username = data['username'] ?? '';
      targetLevel = data['target_level'] ?? '';
      currentAvatarUrl = data['avatarUrl'];

      final String savedModes = data['learning_mode'] ?? '';
      selectedModes = savedModes.split(',').where((e) => e.isNotEmpty).toList();

      if (selectedModes.isEmpty) {
        selectedModes.add(''); // À initialiser avec AppLocalizations
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      AppLogger.error('Erreur lors du chargement du profil: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Sauvegarder le profil
  Future<void> saveProfile() async {
    if (!canSave) {
      throw Exception('Veuillez remplir tous les champs');
    }

    try {
      isLoading = true;
      notifyListeners();

      // --- UPLOAD AVATAR SI NOUVELLE IMAGE ---
      String? newAvatarUrl;
      if (selectedAvatarFile != null) {
        newAvatarUrl = await _uploadAvatar();
        // Nettoyer l'ancienne image
        if (currentAvatarUrl != null && currentAvatarUrl!.isNotEmpty) {
          await _deleteOldAvatar();
        }
      }

      // --- SAUVEGARDER LE PROFIL ---
      await _authService.updateProfile(
        username: username,
        targetLevel: targetLevel,
        learningMode: selectedModes.join(','),
        avatarUrl: newAvatarUrl ?? currentAvatarUrl,
      );

      // --- METTRE À JOUR L'ÉTAT LOCAL ---
      if (newAvatarUrl != null) {
        currentAvatarUrl = newAvatarUrl;
      }
      selectedAvatarFile = null;
      hasUnsavedChanges = false;

      isLoading = false;
      notifyListeners();

      AppLogger.success('Profil sauvegardé avec succès');
    } catch (e) {
      isLoading = false;
      AppLogger.error('Erreur lors de la sauvegarde du profil: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Uploader l'avatar sur Supabase Storage
  Future<String> _uploadAvatar() async {
    if (selectedAvatarFile == null) {
      throw Exception('Aucun fichier sélectionné');
    }

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final fileExtension = selectedAvatarFile!.path.split('.').last;
      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await supabase.storage
          .from(AppConstants.supabaseBucketAvatars)
          .upload(
            fileName,
            selectedAvatarFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabase.storage
          .from(AppConstants.supabaseBucketAvatars)
          .getPublicUrl(fileName);

      AppLogger.success('Avatar uploadé: $fileName');
      return publicUrl;
    } catch (e) {
      AppLogger.error('Erreur lors de l\'upload de l\'avatar: $e');
      rethrow;
    }
  }

  /// Supprimer l'ancienne image de Supabase
  Future<void> _deleteOldAvatar() async {
    if (currentAvatarUrl == null || currentAvatarUrl!.isEmpty) return;

    try {
      final uri = Uri.parse(currentAvatarUrl!);
      final segments = uri.pathSegments;
      final index = segments.indexOf(AppConstants.supabaseBucketAvatars);

      if (index != -1 && index < segments.length - 1) {
        final oldPath = segments.sublist(index + 1).join('/');
        await Supabase.instance.client.storage
            .from(AppConstants.supabaseBucketAvatars)
            .remove([oldPath]);

        AppLogger.success('Ancienne image supprimée: $oldPath');
      }
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression de l\'ancienne image: $e');
      // Ne pas relancer l'erreur, c'est non-bloquant
    }
  }

  /// Mettre à jour le nom d'utilisateur
  void updateUsername(String value) {
    username = value;
    hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Mettre à jour l'objectif
  void updateTargetLevel(String value) {
    targetLevel = value;
    hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Sélectionner un ou plusieurs modes
  void toggleMode(String mode) {
    if (selectedModes.contains(mode)) {
      // Empêcher de désélectionner si c'est le seul
      if (selectedModes.length > 1) {
        selectedModes.remove(mode);
      }
    } else {
      selectedModes.add(mode);
    }
    hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Mettre à jour la photo de profil
  void setAvatarFile(File file) {
    selectedAvatarFile = file;
    hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Réinitialiser les changements non sauvegardés
  void resetChanges() {
    selectedAvatarFile = null;
    hasUnsavedChanges = false;
    notifyListeners();
  }
}
