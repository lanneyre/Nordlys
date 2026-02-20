import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:norvege_app/theme.dart';
import 'package:norvege_app/widgets/login/login_form.dart';
import 'package:norvege_app/widgets/login/login_header.dart';
import 'package:norvege_app/widgets/login/toggle_button.dart';
import '../l10n/app_localizations.dart';
import '../view_models/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
  }

  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _viewModel.submit();
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: AppColors.messagekO,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.loginError(error.toString())),
            backgroundColor: AppColors.messagekO,
          ),
        );
      }
    }

    // Afficher message de succès pour signup
    if (!_viewModel.isLogin && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.loginAccountConfiguredSuccessfully,
          ),
          backgroundColor: AppColors.messageOk,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // --- DICTIONNAIRES (CLÉS -> TRADUCTIONS) ---
    final Map<String, String> levelsMap = {
      'unknown': l10n.loginLevelUnknown,
      'a0': l10n.loginLevelBeginner,
      'a1': l10n.loginLevelFalseBeginner,
      'b1': l10n.loginLevelIntermediate,
      'b2': l10n.loginLevelAdvanced,
    };

    final Map<String, String> modesMap = {
      'mode_fun': l10n.loginModeFun,
      'mode_serious': l10n.loginModeSerious,
      'mode_immersive': l10n.loginModeImmersive,
      'mode_direct': l10n.loginModeDirect,
      'mode_caring': l10n.loginModeCaring,
    };

    // Sécurité : si le niveau est vide (premier lancement), on met 'unknown' par défaut
    if (_viewModel.selectedLevel.isEmpty) {
      _viewModel.updateSelectedLevel('unknown');
    }
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.deepBlue, AppColors.lightBlue],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ValueListenableBuilder<Object?>(
              valueListenable: _viewModel,
              // ignore: unnecessary_underscores
              builder: (context, _, __) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoginHeader(isLogin: _viewModel.isLogin),
                    LoginForm(
                      emailController: _viewModel.emailController,
                      passwordController: _viewModel.passwordController,
                      confirmPasswordController:
                          _viewModel.confirmPasswordController,
                      nameController: _viewModel.nameController,
                      objectiveController: _viewModel.objectiveController,
                      levels: levelsMap.values.toList(),
                      selectedLevel:
                          levelsMap[_viewModel.selectedLevel] ??
                          l10n.loginLevelUnknown,
                      isLogin: _viewModel.isLogin,
                      isLoading: _viewModel.isLoading,
                      onLevelChanged: (translatedLevel) {
                        // On retrouve la clé ('a0') à partir du texte ('Débutant (A0)')
                        final key = levelsMap.entries
                            .firstWhere((e) => e.value == translatedLevel)
                            .key;
                        _viewModel.updateSelectedLevel(key);
                      },
                      allModes: modesMap.values.toList(),
                      selectedModes: _viewModel.selectedModes
                          .map((key) => modesMap[key] ?? key)
                          .toList(),

                      onModeSelected: (selected, translatedMode) {
                        // On retrouve la clé ('fun') à partir du texte ('Ludique')
                        final key = modesMap.entries
                            .firstWhere((e) => e.value == translatedMode)
                            .key;

                        if (selected) {
                          _viewModel.toggleMode(key);
                        } else if (_viewModel.selectedModes.contains(key)) {
                          _viewModel.toggleMode(key);
                        }
                        setState(() {});
                      },
                      onSubmit: _handleSubmit,
                    ),
                    const SizedBox(height: 20),
                    ToggleButton(
                      isLogin: _viewModel.isLogin,
                      onPressed: () {
                        _viewModel.toggleMode();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
