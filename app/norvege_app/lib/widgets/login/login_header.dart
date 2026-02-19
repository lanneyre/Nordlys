import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class LoginHeader extends StatelessWidget {
  final bool isLogin;

  const LoginHeader({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Image.asset('assets/Wolf.png', height: 150),
        const SizedBox(height: 16),
        Text(
          isLogin ? l10n.loginWelcomeBack : l10n.loginCreateProfileTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
