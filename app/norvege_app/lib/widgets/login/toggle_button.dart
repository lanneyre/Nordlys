import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:norvege_app/theme.dart';

class ToggleButton extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onPressed;

  const ToggleButton({
    super.key,
    required this.isLogin,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: isLogin ? l10n.loginNoAccount : l10n.loginAlreadyMember,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
          children: [
            TextSpan(
              text: isLogin ? l10n.loginCreateProfile : l10n.loginSignIn,
              style: const TextStyle(
                color: AppColors.vibrantOrange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.vibrantOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
