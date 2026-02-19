import 'package:flutter/material.dart';

// 1. Notre Palette de Couleurs "Brutes"
class AppColors {
  static const Color deepBlue = Color(0xFF00305A); // Bleu Norvégien
  static const Color lightBlue = Color(0xFF2C5364); // Pour le dégradé
  static const Color vibrantOrange = Color(0xFFFF9F1C); // Action principale
  static const Color softGray = Color(0xFFF4F6F8); // Fond des champs
  static const Color textDark = Color(0xFF2D3436); // Texte principal
  static const Color messageOk = Color.fromARGB(
    255,
    6,
    87,
    0,
  ); // fond des alertes de succès
  static const Color messagekO = Color.fromARGB(
    255,
    180,
    0,
    0,
  ); // fond des alertes d'erreur
}

// 2. Le Thème Global (Configuration automatique des widgets)
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  primaryColor: AppColors.deepBlue,
  scaffoldBackgroundColor: Colors.white,

  // Configuration par défaut des textes
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  ),

  // Configuration par défaut des boutons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.vibrantOrange,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
    ),
  ),

  // Configuration par défaut des champs de texte (Inputs)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.softGray,
    labelStyle: TextStyle(color: Colors.grey[600]),
    prefixIconColor: AppColors.deepBlue,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.deepBlue, width: 2),
    ),
  ),
);
