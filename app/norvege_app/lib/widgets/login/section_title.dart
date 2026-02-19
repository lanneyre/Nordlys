import 'package:flutter/material.dart';
import 'package:norvege_app/theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.deepBlue,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
}
