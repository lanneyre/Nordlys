import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:norvege_app/services/auth_service.dart';
import 'package:norvege_app/theme.dart';
import 'package:norvege_app/widgets/login/login_form.dart';
import 'package:norvege_app/widgets/login/login_header.dart';
import 'package:norvege_app/widgets/login/toggle_button.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _objectiveController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;
  bool _isLogin = true;

  late List<String> _levels;
  late String _selectedLevel;

  late List<String> _allModes;
  late List<String> _selectedModes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _levels = [
      l10n.loginLevelUnknown,
      l10n.loginLevelBeginner,
      l10n.loginLevelFalseBeginner,
      l10n.loginLevelIntermediate,
      l10n.loginLevelAdvanced,
    ];
    _selectedLevel = l10n.loginLevelUnknown;

    _allModes = [
      l10n.loginModeFun,
      l10n.loginModeSerious,
      l10n.loginModeImmersive,
      l10n.loginModeDirect,
      l10n.loginModeCaring,
    ];
    _selectedModes = [l10n.loginModeFun];
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();
      final name = _nameController.text.trim();
      final objective = _objectiveController.text.trim();

      if (_isLogin) {
        await _authService.signIn(email, password);
      } else {
        if (password != confirmPassword) {
          throw AuthException(l10n.loginPasswordsDoNotMatch);
        }
        if (password.length < 6) {
          throw AuthException(l10n.loginPasswordTooShort);
        }
        if (name.isEmpty) throw AuthException(l10n.loginNameIsMandatory);
        if (objective.isEmpty) {
          throw AuthException(l10n.loginObjectiveIsMandatory);
        }
        if (_selectedModes.isEmpty) {
          throw AuthException(l10n.loginChooseAtLeastOneStyle);
        }

        await _authService.signUp(
          email: email,
          password: password,
          displayName: name,
          objective: objective,
          startingLevel: _selectedLevel,
          learningMode: _selectedModes.join(','),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.loginAccountConfiguredSuccessfully),
              backgroundColor: AppColors.messageOk,
            ),
          );
        }
      }
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoginHeader(isLogin: _isLogin),
                LoginForm(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  nameController: _nameController,
                  objectiveController: _objectiveController,
                  selectedLevel: _selectedLevel,
                  levels: _levels,
                  allModes: _allModes,
                  selectedModes: _selectedModes,
                  isLogin: _isLogin,
                  isLoading: _isLoading,
                  onLevelChanged: (val) => setState(() => _selectedLevel = val),
                  onModeSelected: (selected, mode) {
                    setState(() {
                      if (selected) {
                        _selectedModes.add(mode);
                      } else if (_selectedModes.length > 1) {
                        _selectedModes.remove(mode);
                      }
                    });
                  },
                  onSubmit: _submit,
                ),
                const SizedBox(height: 20),
                ToggleButton(
                  isLogin: _isLogin,
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
