// File: lib/core/theme/app_colors.dart
// 🎨 CareSync Patients — Color Configuration
// ✅ Synced with CareSync Doctor app (orange primary theme)

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ══════════════════════════════════════════════════════════════════════════
  // PRIMARY — Orange (matches CareSync Dr exactly)
  // ══════════════════════════════════════════════════════════════════════════

  /// Main Orange — primary actions, headers, main buttons
  static const Color primary = Color(0xFFE67E22);

  /// Light Orange — hover states, secondary backgrounds
  static const Color primaryLight = Color(0xFFF39C12);

  /// Dark Orange — darker elements, emphasis, nav bar
  static const Color primaryDark = Color(0xFFD35400);

  /// Extra Light Orange — subtle card/chip backgrounds
  static const Color primaryExtraLight = Color(0xFFFEEBD8);

  // ══════════════════════════════════════════════════════════════════════════
  // SECONDARY / ACCENT
  // ══════════════════════════════════════════════════════════════════════════

  static const Color secondary = Color(0xFFF39C12);
  static const Color accent    = Color(0xFFE67E22);

  // ══════════════════════════════════════════════════════════════════════════
  // NEUTRAL
  // ══════════════════════════════════════════════════════════════════════════

  static const Color white      = Color(0xFFFFFFFF);
  static const Color black      = Color(0xFF000000);
  static const Color lightGray  = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkGray   = Color(0xFF757575);
  static const Color borderGray = Color(0xFFE0E0E0);

  // ══════════════════════════════════════════════════════════════════════════
  // STATUS COLORS  (identical to Dr app)
  // ══════════════════════════════════════════════════════════════════════════

  static const Color success      = Color(0xFF27AE60);
  static const Color successLight = Color(0xFFD5F4E6);

  static const Color warning      = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFEEBD8);

  static const Color error        = Color(0xFFE74C3C);
  static const Color errorLight   = Color(0xFFFDEDEB);

  static const Color info         = Color(0xFF3498DB);
  static const Color infoLight    = Color(0xFFEBF5FB);

  // ══════════════════════════════════════════════════════════════════════════
  // TEXT
  // ══════════════════════════════════════════════════════════════════════════

  static const Color textPrimary   = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary  = Color(0xFFBDBDBD);
  static const Color textOnDark    = Color(0xFFFFFFFF);

  // ══════════════════════════════════════════════════════════════════════════
  // BACKGROUNDS
  // ══════════════════════════════════════════════════════════════════════════

  static const Color background        = Color(0xFFFAFAFA);
  static const Color backgroundColor   = Color(0xFFFAFAFA); // alias for legacy code
  static const Color cardBackground    = Color(0xFFFFFFFF);
  static const Color surface           = Color(0xFFFFFFFF);
  static const Color surfaceVariant    = Color(0xFFF5F5F5);
  static const Color subtleBackground  = Color(0xFFF5F5F5);
  static const Color darkBackground    = Color(0xFF212121);

  // ══════════════════════════════════════════════════════════════════════════
  // OVERLAY / TRANSPARENCY  (kept from old file so nothing breaks)
  // ══════════════════════════════════════════════════════════════════════════

  static const Color overlay     = Color(0x80000000);
  static const Color transparent = Color(0x00000000);
  static const Color shadow      = Color(0x1F000000);

  // ══════════════════════════════════════════════════════════════════════════
  // GREY SCALE ALIASES  (kept so existing widget refs don't break)
  // ══════════════════════════════════════════════════════════════════════════

  static const Color grey50  = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  static const Color disabled = Color(0xFFBDBDBD);

  // ══════════════════════════════════════════════════════════════════════════
  // GRADIENTS
  // ══════════════════════════════════════════════════════════════════════════

  static const Color gradientStart = Color(0xFFE67E22);
  static const Color gradientEnd   = Color(0xFFF39C12);

  /// Orange gradient — matches Dr app's AppColors.orangeGradient
  static LinearGradient get orangeGradient => const LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Subtle orange gradient for backgrounds
  static LinearGradient get orangeGradientSubtle => LinearGradient(
        colors: [primaryLight.withOpacity(0.3), primary.withOpacity(0.1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Old alias kept so any existing code using primaryGradient still compiles
  static const List<Color> primaryGradient = [primary, primaryDark];
  static const List<Color> successGradient = [success, Color(0xFF388E3C)];
  static const List<Color> errorGradient   = [error,   Color(0xFFD32F2F)];

  // ══════════════════════════════════════════════════════════════════════════
  // SHADOW STYLES  (matches Dr app)
  // ══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1)),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4)),
      ];

  static List<BoxShadow> get largeShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          spreadRadius: 3, blurRadius: 16, offset: const Offset(0, 8)),
      ];

  // ══════════════════════════════════════════════════════════════════════════
  // TRANSPARENCY HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  static Color primaryWithOpacity(double o)  => primary.withOpacity(o);
  static Color secondaryWithOpacity(double o) => secondary.withOpacity(o);
  static Color successWithOpacity(double o)  => success.withOpacity(o);
  static Color errorWithOpacity(double o)    => error.withOpacity(o);
  static Color warningWithOpacity(double o)  => warning.withOpacity(o);

  static Color getContrastText(Color bg) =>
      bg.computeLuminance() > 0.5 ? textPrimary : textOnDark;

  // ══════════════════════════════════════════════════════════════════════════
  // INPUT DECORATION
  // ══════════════════════════════════════════════════════════════════════════

  static InputDecoration getInputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    bool hasError = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: primary) : null,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: primary) : null,
      labelStyle: const TextStyle(color: primary),
      hintStyle: const TextStyle(color: textTertiary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      filled: true,
      fillColor: hasError ? errorLight : white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUTTON STYLES
  // ══════════════════════════════════════════════════════════════════════════

  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primary,
        disabledBackgroundColor: mediumGray,
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        side: const BorderSide(color: primary, width: 2),
        foregroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      );

  static ButtonStyle get successButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: success,
        disabledBackgroundColor: mediumGray,
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      );

  static ButtonStyle get errorButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: error,
        disabledBackgroundColor: mediumGray,
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      );

  // ══════════════════════════════════════════════════════════════════════════
  // TEXT STYLES
  // ══════════════════════════════════════════════════════════════════════════

  static const TextStyle headingLarge  = TextStyle(fontSize: 32, fontWeight: FontWeight.bold,  color: primary);
  static const TextStyle headingMedium = TextStyle(fontSize: 20, fontWeight: FontWeight.bold,  color: primary);
  static const TextStyle headingSmall  = TextStyle(fontSize: 16, fontWeight: FontWeight.w600,  color: primary);
  static const TextStyle bodyText      = TextStyle(fontSize: 14, fontWeight: FontWeight.w400,  color: textPrimary);
  static const TextStyle caption       = TextStyle(fontSize: 12, fontWeight: FontWeight.w400,  color: textSecondary);
  static const TextStyle label         = TextStyle(fontSize: 14, fontWeight: FontWeight.w600,  color: primary);

  // ══════════════════════════════════════════════════════════════════════════
  // THEME DATA
  // ══════════════════════════════════════════════════════════════════════════

  static ThemeData get appTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: secondary,
          surface: white,
          background: background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: white,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          labelStyle: const TextStyle(color: primary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
        outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: white,
          indicatorColor: primaryLight.withOpacity(0.2),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(color: primary, fontWeight: FontWeight.w600);
            }
            return const TextStyle(color: textSecondary);
          }),
        ),
        scaffoldBackgroundColor: background,
        cardColor: white,
      );
}