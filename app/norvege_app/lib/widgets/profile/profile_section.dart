import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../core/constants.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsets padding;

  const ProfileSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      vertical: AppDimensions.gapMedium,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          if (subtitle != null) ...[
            const SizedBox(height: AppDimensions.gapSmall),
            _buildSubtitle(subtitle!),
          ],
          const SizedBox(height: AppDimensions.gapMedium),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.vibrantOrange,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12));
  }
}

/// Widget pour les modes d'apprentissage (Chips réutilisable)
class LearningModeChip extends StatelessWidget {
  final String mode;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const LearningModeChip({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(mode),
      selected: isSelected,
      selectedColor: AppColors.vibrantOrange.withValues(alpha: 0.2),
      checkmarkColor: AppColors.vibrantOrange,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.vibrantOrange : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: onSelected,
    );
  }
}

/// Wrapper pour une liste de chips avec spacing cohérent
class ChipsGrid extends StatelessWidget {
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<String> onItemSelected;
  final double spacing;
  final double runSpacing;

  final Map<String, String> labels;

  const ChipsGrid({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onItemSelected,
    required this.labels,
    this.spacing = 8.0,
    this.runSpacing = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: items
          .map(
            (item) => LearningModeChip(
              mode: labels[item] ?? item,
              isSelected: selectedItems.contains(item),
              onSelected: (_) => onItemSelected(item),
            ),
          )
          .toList(),
    );
  }
}
