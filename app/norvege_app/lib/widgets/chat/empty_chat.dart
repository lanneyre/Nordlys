import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:norvege_app/theme.dart';

class EmptyChat extends StatelessWidget {
  const EmptyChat({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.vibrantOrange,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.chatCoachIsPreparing,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
