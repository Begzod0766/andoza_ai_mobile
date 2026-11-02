import 'package:flutter/material.dart';

/// Delta-mechanic semantic colors — used by every stage-line/progress-bar
/// widget across Batches A/B/C/D/E to express "already existed, excluded
/// from math" (skipped) vs "currently being worked on" (inProgress) vs
/// "finished" (completed) vs "not reached yet" (upcoming).
class _DeltaTokens {
  const _DeltaTokens();

  Color get completed => const Color(0xFF16A34A);
  Color get inProgress => const Color(0xFF2850D0);
  Color get upcoming => const Color(0xFFEEF1F8);
  Color get skipped => const Color(0xFFC4CCE0);
}

/// Room-condition texture colors (korobka/suvoq/shpaklovka) — used by
/// Batch B's texture-choice cards and anywhere the room's baseline state
/// is displayed.
class _RoomStateTokens {
  const _RoomStateTokens();

  Color get korobka => const Color(0xFFE7D9BF);
  Color get suvoq => const Color(0xFFC9CFDD);
  Color get shpaklovka => const Color(0xFFF3F4F6);
}

/// AndozaAI Design Tokens
/// Central design system for consistent styling across all screens.
/// Values are sourced from the approved design spec's "Updated design
/// tokens" section — do not hand-pick replacement values per screen.
class DesignTokens {
  // Color Palette
  // The cobalt of the andoza.ai logo (same family as the web's brand blue).
  static const Color primaryBlue = Color(0xFF2850D0);
  // The logo's orange (the web's warning/accent orange).
  static const Color accentOrange = Color(0xFFF97316);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color darkBg = Color(0xFF0B0E13);
  static const Color textGray = Color(0xFF5A6785);
  static const Color textDark = Color(0xFF1A2340);
  /// Muted body text (captions, helper lines). Was #98A2BC (2.55:1 on white,
  /// failing WCAG AA); #67728E is 4.80:1 on white and 4.59:1 on
  /// [backgroundLight] while staying lighter than [textGray].
  static const Color textMuted = Color(0xFF67728E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF16A34A);

  // Text-safe variants (WCAG AA 4.5:1 on white). [accentOrange], [errorRed]
  // and [successGreen] stay for icons, borders and fills; text and filled
  // buttons with white labels use these.
  static const Color accentOrangeStrong = Color(0xFFC2410C);
  static const Color errorText = Color(0xFFB91C1C);
  static const Color successText = Color(0xFF15803D);
  static const Color warningYellow = Color(0xFFFCD34D);
  static const Color borderGray = Color(0xFFE2E7F2);
  static const Color borderGrayAlt = Color(0xFFDCE4F7);
  static const Color primaryTint = Color(0xFFE3EAFB);
  static const Color existingStateGray = Color(0xFFC4CCE0);
  static const Color dividerGray = Color(0xFFCBD5E1);
  /// Disabled controls only (exempt from text contrast rules).
  static const Color disabledGray = Color(0xFF94A3B8);

  /// Input placeholder text. People read hints, so it needs 4.5:1 too:
  /// #64748B is 4.76:1 on white (disabledGray #94A3B8 was 2.56:1).
  static const Color hintGray = Color(0xFF64748B);
  static const Color shadowGray = Color(0xFF0F172A);

  /// Delta-mechanic semantic colors: `DesignTokens.delta.completed`, etc.
  static const delta = _DeltaTokens();

  /// Room-condition texture colors: `DesignTokens.roomState.korobka`, etc.
  static const roomState = _RoomStateTokens();

  // Typography
  static const String fontFamily = 'Inter';

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textDark,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textDark,
    height: 1.2,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textDark,
    height: 1.3,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textDark,
    height: 1.4,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textDark,
    height: 1.4,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textGray,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textGray,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textGray,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: white,
    height: 1.5,
  );

  // Spacing (screen padding is 20px horizontal per spec)
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
  static const double screenPaddingHorizontal = 20.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  /// Bottom-sheet top corners (24px per spec).
  static const double radiusSheet = 24.0;

  // Shadows — mapped from the spec's CSS box-shadow syntax
  // (offsetY, blur, spread, rgba) to Flutter's BoxShadow.
  /// Card shadow: `0 8px 20px -12px rgba(17,24,39,.16)`
  static const BoxShadow shadowCard = BoxShadow(
    color: Color.fromRGBO(17, 24, 39, 0.16),
    blurRadius: 20.0,
    spreadRadius: -12.0,
    offset: Offset(0, 8),
  );

  /// Elevated/hero card shadow: `0 18px 40px -18px rgba(47,102,144,.28)`
  static const BoxShadow shadowElevated = BoxShadow(
    color: Color.fromRGBO(47, 102, 144, 0.28),
    blurRadius: 40.0,
    spreadRadius: -18.0,
    offset: Offset(0, 18),
  );

  /// Nav bar top-edge shadow: `0 -10px 26px rgba(17,24,39,.06)`
  static const BoxShadow shadowNavBar = BoxShadow(
    color: Color.fromRGBO(17, 24, 39, 0.06),
    blurRadius: 26.0,
    offset: Offset(0, -10),
  );

  /// Primary button shadow: `0 14px 28px -10px rgba(47,102,144,.55)`
  static const BoxShadow shadowPrimaryButton = BoxShadow(
    color: Color.fromRGBO(47, 102, 144, 0.55),
    blurRadius: 28.0,
    spreadRadius: -10.0,
    offset: Offset(0, 14),
  );

  // Legacy shadow names, recomputed to the same spec-accurate values above.
  static const BoxShadow shadowSm = shadowCard;
  static const BoxShadow shadowMd = shadowCard;
  static const BoxShadow shadowLg = shadowElevated;

  // Animation Duration
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Story-circle conic ring rotation (2.5s per spec).
  static const Duration animationStoryRing = Duration(milliseconds: 2500);

  /// Green wireframe LiDAR scan sweep loop (~2.6s per spec).
  static const Duration animationScanSweep = Duration(milliseconds: 2600);

  /// 360° capture target-dot pulse (~1.4s per spec).
  static const Duration animationCapturePulse = Duration(milliseconds: 1400);

  // Button Sizes
  static const double buttonHeightLarge = 56.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightXs = 32.0;

  // Icon Sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;

  // BACKWARD COMPATIBILITY ALIASES (Legacy naming) — only entries still
  // referenced by not-yet-rebuilt screens are kept; confirmed via
  // `grep -rn "DesignTokens\.<name>\b" lib/` before every Step 13 removal.
  // Colors
  static const Color primary = primaryBlue;
  static const Color secondary = accentOrange;
  static const Color success = successGreen;
  static const Color error = errorRed;
  static const Color surface = white;
  static const Color text = textDark;
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  // Typography (map to new names)
  static const TextStyle headingLarge = heading2;
  static const TextStyle headingMedium = heading3;
  static const TextStyle headingSmall = subtitle2;
  static const TextStyle bodyLarge = body1;
  static const TextStyle bodyMedium = body2;
  static const TextStyle bodySmall = caption;
  static const TextStyle labelMedium = button;

  // Spacing (map to new names)
  static const double spacing4 = spacingXs;
  static const double spacing8 = spacingSm;
  static const double spacing12 = 12.0; // was mis-aliased to spacingSm (8.0)
  static const double spacing16 = spacingMd;
  static const double spacing24 = spacingLg;
  static const double spacing32 = spacingXl;
  static const double spacing40 = 40.0; // was mis-aliased to spacingXxl (48.0)

  // Border radius (map to new names)
  static const double radiusMedium = radiusMd;
  static const double radiusLarge = radiusLg;
}

/// Theme Data for the app
class AndozaTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: DesignTokens.fontFamily,
      scaffoldBackgroundColor: DesignTokens.backgroundLight,
      primaryColor: DesignTokens.primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: DesignTokens.primaryBlue,
        secondary: DesignTokens.accentOrange,
        tertiary: DesignTokens.accentOrange,
        surface: DesignTokens.white,
        error: DesignTokens.errorText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DesignTokens.backgroundLight,
        foregroundColor: DesignTokens.textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: DesignTokens.heading3,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primaryBlue,
          foregroundColor: DesignTokens.white,
          // A soft brand-coloured glow under the pill, as on the web's primary button.
          elevation: 3,
          shadowColor: DesignTokens.primaryBlue.withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingLg,
            vertical: DesignTokens.spacingMd,
          ),
          shape: const StadiumBorder(),
          textStyle: DesignTokens.button,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DesignTokens.primaryBlue,
          foregroundColor: DesignTokens.white,
          shape: const StadiumBorder(),
          textStyle: DesignTokens.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.primaryBlue,
          textStyle: DesignTokens.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primaryBlue,
          side: const BorderSide(color: DesignTokens.primaryBlue),
          shape: const StadiumBorder(),
          textStyle: DesignTokens.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingMd,
          vertical: DesignTokens.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(color: DesignTokens.borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(color: DesignTokens.borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: DesignTokens.primaryBlue,
            width: 2,
          ),
        ),
        hintStyle: DesignTokens.body2.copyWith(
          color: DesignTokens.hintGray,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DesignTokens.borderGray,
        disabledColor: DesignTokens.disabledGray,
        selectedColor: DesignTokens.primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingSm),
        labelStyle: DesignTokens.body2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: DesignTokens.fontFamily,
      scaffoldBackgroundColor: DesignTokens.darkBg,
      primaryColor: DesignTokens.primaryBlue,
      colorScheme: const ColorScheme.dark(
        primary: DesignTokens.primaryBlue,
        secondary: DesignTokens.accentOrange,
        tertiary: DesignTokens.accentOrange,
        surface: Color(0xFF1A2230),
        error: DesignTokens.errorText,
      ),
    );
  }
}
