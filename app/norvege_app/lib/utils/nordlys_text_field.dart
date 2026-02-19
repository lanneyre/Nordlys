import 'package:flutter/material.dart';
import '../theme.dart'; // N'oubliez pas d'importer vos couleurs !

class NordlysTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  // --- LES NOUVEAUX PARAMÈTRES ---
  final int minLines;
  final int? maxLines;

  // 1. ON AJOUTE LE PARAMÈTRE ICI 👇
  final ValueChanged<String>? onChanged;

  const NordlysTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false, // Par défaut, ce n'est pas un mot de passe
    this.keyboardType = TextInputType.text,

    this.minLines = 1, // 1 ligne minimum par défaut
    this.maxLines = 1, // 1 ligne maximum par défaut (comportement classique)
    // 2. ON LE DÉCLARE DANS LE CONSTRUCTEUR 👇
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword, // Pour cacher le texte si c'est un mot de passe
      keyboardType: keyboardType,

      minLines: minLines,
      maxLines: isPassword ? 1 : maxLines,

      // 3. ON LE PASSE AU VRAI TEXTFIELD 👇
      onChanged: onChanged,

      decoration: InputDecoration(
        // --- LE FAMEUX LABEL EN FORME DE BADGE ---
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.vibrantOrange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // --- L'ICÔNE (SI ELLE EXISTE) ---
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.deepBlue)
            : null,

        // Le suffixIcon (par exemple le petit oeil pour les mots de passe)
        suffixIcon: suffixIcon,

        // --- LES BORDURES ---
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.vibrantOrange,
            width: 2,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
