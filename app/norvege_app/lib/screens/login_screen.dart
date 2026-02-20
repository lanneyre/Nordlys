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
  late List<String> _levels = [];
  late List<String> _allModes = [];

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;

    // Initialiser les niveaux
    _levels = [
      l10n.loginLevelUnknown,
      l10n.loginLevelBeginner,
      l10n.loginLevelFalseBeginner,
      l10n.loginLevelIntermediate,
      l10n.loginLevelAdvanced,
    ];
    if (_viewModel.selectedLevel.isEmpty && _levels.isNotEmpty) {
      _viewModel.updateSelectedLevel(_levels[0]);
    }

    // Initialiser les modes
    _allModes = [
      l10n.loginModeFun,
      l10n.loginModeSerious,
      l10n.loginModeImmersive,
      l10n.loginModeDirect,
      l10n.loginModeCaring,
    ];
    if (_viewModel.selectedModes.isEmpty && _allModes.isNotEmpty) {
      _viewModel.toggleMode();
    }
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
                      selectedLevel: _viewModel.selectedLevel,
                      levels: _levels,
                      allModes: _allModes,
                      selectedModes: _viewModel.selectedModes,
                      isLogin: _viewModel.isLogin,
                      isLoading: _viewModel.isLoading,
                      onLevelChanged: _viewModel.updateSelectedLevel,
                      onModeSelected: (selected, mode) {
                        if (selected) {
                          _viewModel.toggleMode(mode);
                        } else if (_viewModel.selectedModes.contains(mode)) {
                          _viewModel.toggleMode(mode);
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
