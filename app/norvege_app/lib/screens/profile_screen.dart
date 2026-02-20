/// ProfileScreen - VERSION REFACTORISÉE
/// Utilise ProfileViewModel pour la logique métier
/// Maintenant plus lisible et testable

import 'dart:io';
import 'package:flutter/material.dart';
import '../core/core.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../theme.dart';
import '../utils/nordlys_text_field.dart';
import '../utils/profile_avatar.dart';
import '../widgets/profile/profile_section.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/profile/level_dashboard.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileViewModel _viewModel;
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  late List<String> _allModes = [];

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel();
    _loadData();
  }

  void _loadData() async {
    try {
      await _viewModel.loadProfile();
      if (mounted) {
        setState(() {
          _nameController.text = _viewModel.username;
          _targetController.text = _viewModel.targetLevel;
        });
      }
    } catch (e) {
      _showError(e);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _allModes = [
      l10n.loginModeFun,
      l10n.loginModeSerious,
      l10n.loginModeImmersive,
      l10n.loginModeDirect,
      l10n.loginModeCaring,
    ];
  }

  Future<void> _save() async {
    // Validation
    final nameError = ValidationHelper.validateUsername(_nameController.text);
    final objectiveError = ValidationHelper.validateObjective(
      _targetController.text,
    );
    final modesError = ValidationHelper.validateModeSelection(
      _viewModel.selectedModes,
    );

    if (nameError != null || objectiveError != null || modesError != null) {
      _showError(nameError ?? objectiveError ?? modesError);
      return;
    }

    try {
      _viewModel.updateUsername(_nameController.text);
      _viewModel.updateTargetLevel(_targetController.text);
      await _viewModel.saveProfile();

      if (mounted) {
        _showSuccess('Profil mis à jour avec succès!');
      }
    } catch (e) {
      _showError(e);
    }
  }

  Future<bool?> _showExitWarning() {
    if (!mounted) return Future.value(false);
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileUnsavedChanges),
        content: Text(l10n.profileUnsavedChangesWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.profileCancel,
              style: const TextStyle(color: AppColors.lightBlue),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vibrantOrange,
            ),
            child: Text(
              l10n.profileQuitWithoutSaving,
              style: const TextStyle(color: AppColors.softGray),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(dynamic error) {
    final l10n = AppLocalizations.of(context)!;
    final appError = ErrorHandler.handleError(error, l10n);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appError.message),
          backgroundColor: AppColors.messagekO,
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.messageOk),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_viewModel.hasUnsavedChanges,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        final shouldPop = await _showExitWarning() ?? false;
        if (!mounted) return;

        if (shouldPop) {
          Navigator.of(context).pop();
          _viewModel.resetChanges();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.deepBlue,
        appBar: AppBar(
          title: Text(
            l10n.profileMyProfile,
            style: const TextStyle(color: AppColors.deepBlue),
          ),
          backgroundColor: AppColors.softGray,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.deepBlue),
        ),
        body: _viewModel.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.vibrantOrange,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- AVATAR ---
                    Center(
                      child: ProfileAvatar(
                        radius: AppDimensions.avatarRadiusDefault,
                        initialImageUrl: _viewModel.currentAvatarUrl,
                        onImageSelected: (File imageFile) {
                          _viewModel.setAvatarFile(imageFile);
                        },
                      ),
                    ),
                    const SizedBox(height: AppDimensions.gapLarge),

                    // --- SECTION 1: QUI ÊTES-VOUS ---
                    ProfileSection(
                      title: l10n.profileWhoAreYou,
                      child: NordlysTextField(
                        controller: _nameController,
                        label: l10n.profileFirstNameOrNickname,
                        prefixIcon: Icons.person_outline,
                        keyboardType: TextInputType.text,
                        onChanged: (val) => _viewModel.updateUsername(val),
                      ),
                    ),

                    // --- SECTION 2: OBJECTIF ---
                    ProfileSection(
                      title: l10n.profileYourObjective,
                      subtitle: l10n.profileDescribeYourGoal,
                      child: NordlysTextField(
                        controller: _targetController,
                        label: l10n.profileFreeObjective,
                        prefixIcon: Icons.flag_outlined,
                        keyboardType: TextInputType.text,
                        maxLines: 5,
                        onChanged: (val) => _viewModel.updateTargetLevel(val),
                      ),
                    ),
                    // --- NOUVELLE SECTION: PROGRESSION ---
                    ProfileSection(
                      title: l10n.profileProgression,
                      child: LevelDashboard(
                        currentLevel: _viewModel.currentLevel,
                      ),
                    ),
                    // --- SECTION 3: STYLES D'APPRENTISSAGE ---
                    ProfileSection(
                      title: l10n.profileCoachingStyle,
                      subtitle: l10n.profileSelectOneOrMoreStyles,
                      child: ChipsGrid(
                        items: _allModes,
                        selectedItems: _viewModel.selectedModes,
                        onItemSelected: (mode) {
                          setState(() {
                            _viewModel.toggleMode(mode);
                          });
                        },
                      ),
                    ),

                    // --- SECTION 4: LANGUE ---
                    ProfileSection(
                      title: l10n.profileLanguage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: appLocale.value.languageCode,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.language,
                              color: AppColors.deepBlue,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingMedium,
                              vertical: AppDimensions.paddingMedium,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'fr',
                              child: Text(l10n.langueFr),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(l10n.langueEn),
                            ),
                          ],
                          onChanged: (String? newLang) async {
                            if (newLang != null) {
                              appLocale.value = Locale(newLang);
                              // Persister
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.gapLarge),

                    // --- BOUTON SAUVEGARDER ---
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _viewModel.isLoading ? null : _save,
                        child: _viewModel.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.profileSAVE),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }
}
