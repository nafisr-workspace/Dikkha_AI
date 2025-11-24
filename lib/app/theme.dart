import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Colors
  static const Color primaryViolet = Color(0xFF6C63FF);
  static const Color deepViolet = Color(0xFF5A52D5);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Surfaces
  static const Color creamyWhite = Color(0xFFFDFAF5);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lavenderMist = Color(0xFFEEEBFF);

  // Text
  static const Color deepSlate = Color(0xFF2D2D3D);
  static const Color softGrey = Color(0xFF787885);

  // Dividers
  static const Color paleGrey = Color(0xFFE0E0E0);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryViolet,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.lavenderMist,
        onPrimaryContainer: AppColors.deepSlate,
        secondary: AppColors.primaryViolet,
        onSecondary: AppColors.onPrimary,
        secondaryContainer: AppColors.lavenderMist,
        onSecondaryContainer: AppColors.deepSlate,
        tertiary: AppColors.primaryViolet,
        onTertiary: AppColors.onPrimary,
        error: Color(0xFFBA1A1A),
        onError: AppColors.onPrimary,
        surface: AppColors.creamyWhite,
        onSurface: AppColors.deepSlate,
        surfaceContainerHighest: AppColors.pureWhite,
        outline: AppColors.paleGrey,
        outlineVariant: AppColors.paleGrey,
      ),
      scaffoldBackgroundColor: AppColors.creamyWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.creamyWhite,
        foregroundColor: AppColors.deepSlate,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: _buildTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryViolet,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryViolet,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          side: const BorderSide(color: AppColors.primaryViolet),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryViolet,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.paleGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.paleGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryViolet, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.roboto(
          color: AppColors.softGrey,
          fontSize: 16,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.pureWhite,
        selectedColor: AppColors.lavenderMist,
        labelStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: AppColors.deepSlate,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.paleGrey),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.pureWhite,
        indicatorColor: AppColors.lavenderMist,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryViolet,
            );
          }
          return GoogleFonts.roboto(
            fontSize: 12,
            color: AppColors.softGrey,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryViolet);
          }
          return const IconThemeData(color: AppColors.softGrey);
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.paleGrey, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.paleGrey,
        thickness: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.roboto(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: AppColors.deepSlate,
      ),
      displayMedium: GoogleFonts.roboto(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: AppColors.deepSlate,
      ),
      displaySmall: GoogleFonts.roboto(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.deepSlate,
      ),
      headlineLarge: GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.deepSlate,
      ),
      headlineMedium: GoogleFonts.roboto(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.deepSlate,
      ),
      headlineSmall: GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.deepSlate,
      ),
      titleLarge: GoogleFonts.roboto(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: AppColors.deepSlate,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.deepSlate,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.deepSlate,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.deepSlate,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.deepSlate,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.softGrey,
      ),
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.deepSlate,
      ),
      labelMedium: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.deepSlate,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.softGrey,
      ),
    );
  }
}

