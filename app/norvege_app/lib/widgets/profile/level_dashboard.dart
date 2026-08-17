import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../core/constants.dart'; // <-- Ajout de vos dimensions !
import '../../l10n/app_localizations.dart';

class LevelDashboard extends StatelessWidget {
  final String? currentLevel;

  const LevelDashboard({super.key, required this.currentLevel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // <-- AJOUTEZ CECI ICI
    const levels = ['A0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

    String currentLevelStr = (currentLevel ?? 'A0').trim().toUpperCase();
    if (!levels.contains(currentLevelStr)) {
      currentLevelStr = 'A0';
    }

    final int currentIndex = levels.indexOf(currentLevelStr);

    return Container(
      // Utilisation de vos dimensions globales
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMedium,
        ), // Cohérent avec le Dropdown
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🛑 LE TITRE "VOTRE PROGRESSION" A ÉTÉ SUPPRIMÉ D'ICI

          // LA FRISE HORIZONTALE
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(levels.length * 2 - 1, (index) {
              if (index % 2 == 0) {
                int levelIndex = index ~/ 2;
                bool isAchieved = levelIndex <= currentIndex;
                bool isCurrent = levelIndex == currentIndex;

                return Column(
                  children: [
                    SizedBox(
                      height: 24,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isCurrent ? 24 : 14,
                          height: isCurrent ? 24 : 14,
                          decoration: BoxDecoration(
                            color: isAchieved
                                ? AppColors.vibrantOrange
                                : Colors.grey.shade200,
                            shape: BoxShape.circle,
                            border: isCurrent
                                ? Border.all(
                                    color: AppColors.vibrantOrange.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 4,
                                  )
                                : null,
                          ),
                          child: isCurrent
                              ? const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      levels[levelIndex],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isAchieved
                            ? AppColors.deepBlue
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                );
              } else {
                int lineIndex = index ~/ 2;
                bool isLineActive = lineIndex < currentIndex;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      color: isLineActive
                          ? AppColors.vibrantOrange
                          : Colors.grey.shade200,
                    ),
                  ),
                );
              }
            }),
          ),

          const SizedBox(height: AppDimensions.gapLarge),

          // LE TEXTE D'ENCOURAGEMENT
          Center(
            child: Text(
              _getMotivationText(currentLevelStr, l10n),
              style: const TextStyle(
                color: AppColors.deepBlue,
                fontStyle: FontStyle.italic,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationText(String level, AppLocalizations l10n) {
    switch (level) {
      case 'A0':
        return l10n.levelMotivationA0;
      case 'A1':
        return l10n.levelMotivationA1;
      case 'A2':
        return l10n.levelMotivationA2;
      case 'B1':
        return l10n.levelMotivationB1;
      case 'B2':
        return l10n.levelMotivationB2;
      case 'C1':
        return l10n.levelMotivationC1;
      case 'C2':
        return l10n.levelMotivationC2;
      default:
        return l10n.levelMotivationDefault;
    }
  }
}
