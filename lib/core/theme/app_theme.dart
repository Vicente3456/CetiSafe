import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ── TEMA CLARO ──────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.grisClaro,
    colorScheme: const ColorScheme.light(
      primary: AppColors.vino,
      onPrimary: AppColors.blanco,
      secondary: AppColors.vinoClaro,
      onSecondary: AppColors.blanco,
      surface: AppColors.blanco,
      onSurface: AppColors.textoOscuro,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.montserratTextTheme().copyWith(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textoOscuro,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textoOscuro,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 16,
        color: AppColors.textoOscuro,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        color: AppColors.textoOscuro,
      ),
      labelLarge: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.blanco,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.vino,
      foregroundColor: AppColors.blanco,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.blanco,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.vino,
        foregroundColor: AppColors.blanco,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.blanco,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grisClaro),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.textoGris.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.vino, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: GoogleFonts.montserrat(
        color: AppColors.textoGris,
        fontSize: 14,
      ),
      // ── Color del texto escrito en modo claro ──
      hintStyle: GoogleFonts.montserrat(
        color: AppColors.textoGris,
        fontSize: 14,
      ),
    ),
    // ── Color del texto en inputs modo claro ──
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.vino,
    ),
    cardTheme: CardThemeData(
      color: AppColors.blanco,
      elevation: 2,
      shadowColor: AppColors.negro.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.blanco,
      selectedItemColor: AppColors.vino,
      unselectedItemColor: AppColors.textoGris,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.textoGris.withValues(alpha: 0.2),
      thickness: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.vino;
        return AppColors.textoGris;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.vino.withValues(alpha: 0.4);
        }
        return AppColors.textoGris.withValues(alpha: 0.3);
      }),
    ),
  );

  // ── TEMA OSCURO ──────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.negro,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.vinoClaro,
      onPrimary: AppColors.blanco,
      secondary: AppColors.vino,
      onSecondary: AppColors.blanco,
      surface: AppColors.grisOscuro,
      onSurface: AppColors.textoClaro,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.montserratTextTheme().copyWith(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textoClaro,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textoClaro,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 16,
        color: AppColors.textoClaro,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        color: AppColors.textoClaro,
      ),
      labelLarge: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.blanco,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.grisOscuro,
      foregroundColor: AppColors.blanco,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.blanco,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.vinoClaro,
        foregroundColor: AppColors.blanco,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grisMedio,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grisMedio),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.textoGris.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.vinoClaro, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: GoogleFonts.montserrat(
        color: AppColors.textoGris,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.montserrat(
        color: AppColors.textoGris,
        fontSize: 14,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.vinoClaro,
    ),
    cardTheme: CardThemeData(
      color: AppColors.grisOscuro,
      elevation: 2,
      shadowColor: AppColors.negro.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.grisOscuro,
      selectedItemColor: AppColors.vinoClaro,
      unselectedItemColor: AppColors.textoGris,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.textoGris.withValues(alpha: 0.2),
      thickness: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.vinoClaro;
        return AppColors.textoGris;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.vinoClaro.withValues(alpha: 0.4);
        }
        return AppColors.textoGris.withValues(alpha: 0.3);
      }),
    ),
  );
}
