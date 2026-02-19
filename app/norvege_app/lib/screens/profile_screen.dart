import 'dart:io';

import 'package:flutter/material.dart';
import 'package:norvege_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../utils/app_logger.dart';
import '../utils/nordlys_text_field.dart';
import '../utils/profile_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _authService = AuthService();
  bool _hasUnsavedChanges = false;

  File?
  _selectedAvatarFile; // L'image que l'utilisateur vient de choisir sur son téléphone
  String? _currentAvatarUrl; // Le lien de l'image DÉJÀ sauvegardée sur Supabase

  bool _isLoading = true;

  late List<String> _allModes;
  List<String> _selectedModes = [];

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _authService.getProfile();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _nameController.text = data['username'] ?? '';
        _targetController.text = data['target_level'] ?? '';

        // On charge l'URL de l'image si elle existe dans la base de données !
        _currentAvatarUrl = data['avatarUrl'];

        String savedModes = data['learning_mode'] ?? l10n.loginModeFun;
        _selectedModes = savedModes
            .split(',')
            .where((e) => e.isNotEmpty)
            .toList();

        if (_selectedModes.isEmpty) _selectedModes.add(_allModes[0]);

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileError(e.toString()))));
    }
  }

  Future<void> _saveProfile() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (_targetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileObjectiveCannotBeEmpty)),
      );
      return;
    }
    if (_selectedModes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileSelectAtLeastOneStyle)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // On déclare la variable ici pour pouvoir l'utiliser plus bas
      String? newAvatarUrl;

      // --- 1. SAUVEGARDE DE L'IMAGE (Si une nouvelle a été choisie) ---
      if (_selectedAvatarFile != null) {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;

        if (user != null) {
          final fileExtension = _selectedAvatarFile!.path.split('.').last;
          final fileName =
              '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

          // On envoie la NOUVELLE image
          await supabase.storage
              .from('avatars')
              .upload(
                fileName,
                _selectedAvatarFile!,
                fileOptions: const FileOptions(upsert: true),
              );

          newAvatarUrl = supabase.storage
              .from('avatars')
              .getPublicUrl(fileName);

          // -----------------------------------------------------------------
          // --- NOUVEAU : SUPPRESSION DE L'ANCIENNE IMAGE SUR LE CLOUD ---
          // -----------------------------------------------------------------
          if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
            try {
              // L'URL ressemble à ça : https://[...]/public/avatars/ID_USER/1234.jpg
              // On va extraire juste : "ID_USER/1234.jpg"
              final uri = Uri.parse(_currentAvatarUrl!);
              final segments = uri.pathSegments;
              final index = segments.indexOf('avatars');

              if (index != -1 && index < segments.length - 1) {
                // On récupère tout ce qui est après le mot "avatars"
                final oldPath = segments.sublist(index + 1).join('/');

                // On demande à Supabase de jeter le vieux fichier à la poubelle 🗑️
                await supabase.storage.from('avatars').remove([oldPath]);
                AppLogger.success(
                  'Ancienne image supprimée avec succès : $oldPath',
                );
              }
            } catch (e) {
              AppLogger.error(
                'Erreur lors du nettoyage de l\'ancienne image: $e',
              );
            }
          }
          // -----------------------------------------------------------------
        }
      }

      // --- 2. SAUVEGARDE DU RESTE DU PROFIL ---
      await _authService.updateProfile(
        username: _nameController.text.trim(),
        targetLevel: _targetController.text.trim(),
        learningMode: _selectedModes.join(','),

        // On envoie la nouvelle image, ou on garde l'ancienne si on n'a rien changé
        avatarUrl: newAvatarUrl ?? _currentAvatarUrl,
      );

      // --- LA MODIFICATION EST ICI ---
      if (mounted) {
        // 1. On arrête le chargement pour pouvoir re-cliquer plus tard
        setState(() {
          _isLoading = false;
          _hasUnsavedChanges = false; // <-- On réinitialise la sécurité !
          // On met à jour la variable locale avec la nouvelle image !
          if (newAvatarUrl != null) {
            _currentAvatarUrl = newAvatarUrl;
          }
        });

        // 2. On affiche le message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileProfileUpdated),
            backgroundColor: AppColors.messageOk,
          ),
        );

        // 3. ON SUPPRIME la ligne Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileError(e.toString())),
          backgroundColor: AppColors.messagekO,
        ),
      );
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
            onPressed: () => Navigator.pop(context, false), // Reste sur la page
            child: Text(
              l10n.profileCancel,
              style: const TextStyle(color: AppColors.lightBlue),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Autorise la sortie
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      // On autorise la sortie naturelle SEULEMENT s'il n'y a pas de changements non sauvegardés
      canPop: !_hasUnsavedChanges,

      // Cette fonction se déclenche quand l'utilisateur essaie de faire "Retour"
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return; // Si la page a déjà réussi à se fermer, on ne fait rien
        }

        // Sinon, on affiche notre pop-up
        final bool shouldPop = await _showExitWarning() ?? false;

        // Vérifier que le widget est toujours monté après l'opération async
        if (!mounted) return;

        // Si l'utilisateur clique sur "Quitter sans sauvegarder", on force la fermeture
        if (shouldPop) {
          Navigator.of(context).pop();
        }
      },

      // Votre page actuelle ne change pas !
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.vibrantOrange,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- AVATAR ---
                    Center(
                      child: ProfileAvatar(
                        radius: 70,
                        // On passe l'URL de l'image chargée depuis la BDD
                        initialImageUrl: _currentAvatarUrl,
                        onImageSelected: (File imageFile) {
                          setState(() {
                            // On mémorise la photo choisie pour quand on cliquera sur "Enregistrer"
                            _selectedAvatarFile = imageFile;
                            _hasUnsavedChanges = true;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle(l10n.profileWhoAreYou),
                    const SizedBox(height: 16),

                    NordlysTextField(
                      controller: _nameController,
                      label: l10n.profileFirstNameOrNickname,
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.text,
                      onChanged: (val) =>
                          setState(() => _hasUnsavedChanges = true),
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle(l10n.profileYourObjective),
                    const SizedBox(height: 8),
                    Text(
                      l10n.profileDescribeYourGoal,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),

                    NordlysTextField(
                      controller: _targetController,
                      label: l10n.profileFreeObjective,
                      prefixIcon: Icons.flag_outlined,
                      keyboardType: TextInputType.text,
                      maxLines: 5,
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle(l10n.profileCoachingStyle),
                    const SizedBox(height: 8),
                    Text(
                      l10n.profileSelectOneOrMoreStyles,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _allModes.map((mode) {
                        final isSelected = _selectedModes.contains(mode);
                        return FilterChip(
                          label: Text(mode),
                          selected: isSelected,
                          selectedColor: AppColors.vibrantOrange.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: AppColors.vibrantOrange,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.vibrantOrange
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedModes.add(mode);
                              } else {
                                if (_selectedModes.length > 1) {
                                  _selectedModes.remove(mode);
                                }
                              }
                              _hasUnsavedChanges = true;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    // --- NOUVELLE SECTION : LANGUE ---
                    const SizedBox(height: 24),
                    _buildSectionTitle(l10n.profileLanguage),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        // On lit la langue actuelle directement depuis la variable globale
                        value: appLocale.value.languageCode,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.language,
                            color: AppColors.deepBlue,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
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
                            // On change la langue instantanément !
                            appLocale.value = Locale(newLang);

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('app_language', newLang);
                            // On signale qu'il y a un changement non sauvegardé (optionnel,
                            // car la langue change en temps réel de toute façon)
                            setState(() => _hasUnsavedChanges = true);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: Text(l10n.profileSAVE),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.vibrantOrange,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 1.2,
      ),
    );
  }
}
