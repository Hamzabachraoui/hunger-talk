import 'package:flutter/material.dart';

/// Palette de couleurs douces pour l'application Hunger-Talk
class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF6B9BD1); // Bleu doux
  static const Color primaryDark = Color(0xFF4A7BA7);
  static const Color primaryLight = Color(0xFF8FB3E0);

  // Couleurs secondaires
  static const Color secondary = Color(0xFF9BC4A0); // Vert doux
  static const Color secondaryDark = Color(0xFF7BA381);
  static const Color secondaryLight = Color(0xFFB8D9BE);

  // Couleurs d'accent
  static const Color accent = Color(0xFFFFB84D); // Orange doux
  static const Color accentDark = Color(0xFFFF9A1F);
  static const Color accentLight = Color(0xFFFFD17A);

  // Couleurs de fond
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F5);

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFFADB5BD);

  // Couleurs d'état
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  // Couleurs pour les catégories
  static const Color categoryFruits = Color(0xFFFF6B6B);
  static const Color categoryVegetables = Color(0xFF51CF66);
  static const Color categoryDairy = Color(0xFFFFD93D);
  static const Color categoryMeat = Color(0xFFFF8787);
  static const Color categoryGrains = Color(0xFFD4A574);
  static const Color categoryBeverages = Color(0xFF74C0FC);

  // Couleurs pour les états de stock
  static const Color stockExpiring = Color(0xFFFF9800);
  static const Color stockExpired = Color(0xFFE53935);
  static const Color stockLow = Color(0xFFFFC107);
  static const Color stockNormal = Color(0xFF4CAF50);

  // Dégradés
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDark],
  );
}

