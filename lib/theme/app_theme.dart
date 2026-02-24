import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DevPulseColors {
  // Accent colors (shared between themes)
  static const primary = Color(0xFF8B72FF);
  static const success = Color(0xFF34D1A0);
  static const warning = Color(0xFFF0C95C);
  static const danger = Color(0xFFE8646A);
  static const info = Color(0xFF6AB8E8);

  // Dark theme
  static const darkBg = Color(0xFF08080D);
  static const darkSurface = Color(0xFF101016);
  static const darkSurfaceElevated = Color(0xFF161620);
  static const darkNav = Color(0xF20B0B11); // rgba(11,11,17,0.95)
  static const darkBorder = Color(0x0AFFFFFF); // rgba(255,255,255,0.04)
  static const darkBorderSubtle = Color(0x08FFFFFF); // rgba(255,255,255,0.03)
  static const darkFill = Color(0x0AFFFFFF); // rgba(255,255,255,0.04)
  static const darkFill2 = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)
  static const darkFill3 = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  static const darkText = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xCCFFFFFF); // rgba(255,255,255,0.80)
  static const darkTextTertiary = Color(0xB3FFFFFF); // rgba(255,255,255,0.70)
  static const darkTextMuted = Color(0xFF5C5C6F);
  static const darkTextDim = Color(0xFF3A3A48);
  static const darkTextGhost = Color(0xFF2A2A35);
  static const darkTextFaint = Color(0xFF252530);
  static const darkTextInvisible = Color(0xFF1A1A24);
  static const darkHomeIndicator = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  static const darkOverlay = Color(0x80000000); // rgba(0,0,0,0.50)
  static const darkOverlayHeavy = Color(0x99000000); // rgba(0,0,0,0.60)
  static const darkNavActive = Color(0xFFFFFFFF);
  static const darkNavInactive = Color(0xFF3A3A48);
  static const darkBarInactive = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)
  static const darkRingTrack = Color(0x0AFFFFFF); // rgba(255,255,255,0.04)
  static const darkGridEmpty = Color(0x08FFFFFF); // rgba(255,255,255,0.03)

  // Light theme
  static const lightBg = Color(0xFFF4F4F6);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceElevated = Color(0xFFF8F8FA);
  static const lightNav = Color(0xEBFFFFFF); // rgba(255,255,255,0.92)
  static const lightBorder = Color(0x12000000); // rgba(0,0,0,0.07)
  static const lightBorderSubtle = Color(0x0A000000); // rgba(0,0,0,0.04)
  static const lightFill = Color(0x08000000); // rgba(0,0,0,0.03)
  static const lightFill2 = Color(0x0F000000); // rgba(0,0,0,0.06)
  static const lightFill3 = Color(0x1A000000); // rgba(0,0,0,0.10)
  static const lightText = Color(0xFF1A1A2E);
  static const lightTextSecondary = Color(0xC71A1A2E); // rgba(26,26,46,0.78)
  static const lightTextTertiary = Color(0x991A1A2E); // rgba(26,26,46,0.60)
  static const lightTextMuted = Color(0xFF6B7280);
  static const lightTextDim = Color(0xFF9CA3AF);
  static const lightTextGhost = Color(0xFFC5C8CE);
  static const lightTextFaint = Color(0xFFD1D5DB);
  static const lightTextInvisible = Color(0xFFE8E8ED);
  static const lightHomeIndicator = Color(0x1F000000); // rgba(0,0,0,0.12)
  static const lightOverlay = Color(0x4D000000); // rgba(0,0,0,0.30)
  static const lightOverlayHeavy = Color(0x66000000); // rgba(0,0,0,0.40)
  static const lightNavActive = Color(0xFF1A1A2E);
  static const lightNavInactive = Color(0xFF9CA3AF);
  static const lightBarInactive = Color(0x0F000000); // rgba(0,0,0,0.06)
  static const lightRingTrack = Color(0x0D000000); // rgba(0,0,0,0.05)
  static const lightGridEmpty = Color(0x0A000000); // rgba(0,0,0,0.04)
  static const lightCardShadow = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x05000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
}

class DevPulseTheme {
  final Color bg;
  final Color surface;
  final Color surfaceElevated;
  final Color nav;
  final Color border;
  final Color borderSubtle;
  final Color fill;
  final Color fill2;
  final Color fill3;
  final Color text;
  final Color textSecondary;
  final Color textTertiary;
  final Color textMuted;
  final Color textDim;
  final Color textGhost;
  final Color textFaint;
  final Color textInvisible;
  final Color homeIndicator;
  final Color overlay;
  final Color overlayHeavy;
  final Color navActive;
  final Color navInactive;
  final Color barInactive;
  final Color ringTrack;
  final Color gridEmpty;
  final List<BoxShadow> cardShadow;

  const DevPulseTheme({
    required this.bg,
    required this.surface,
    required this.surfaceElevated,
    required this.nav,
    required this.border,
    required this.borderSubtle,
    required this.fill,
    required this.fill2,
    required this.fill3,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.textMuted,
    required this.textDim,
    required this.textGhost,
    required this.textFaint,
    required this.textInvisible,
    required this.homeIndicator,
    required this.overlay,
    required this.overlayHeavy,
    required this.navActive,
    required this.navInactive,
    required this.barInactive,
    required this.ringTrack,
    required this.gridEmpty,
    required this.cardShadow,
  });

  static const dark = DevPulseTheme(
    bg: DevPulseColors.darkBg,
    surface: DevPulseColors.darkSurface,
    surfaceElevated: DevPulseColors.darkSurfaceElevated,
    nav: DevPulseColors.darkNav,
    border: DevPulseColors.darkBorder,
    borderSubtle: DevPulseColors.darkBorderSubtle,
    fill: DevPulseColors.darkFill,
    fill2: DevPulseColors.darkFill2,
    fill3: DevPulseColors.darkFill3,
    text: DevPulseColors.darkText,
    textSecondary: DevPulseColors.darkTextSecondary,
    textTertiary: DevPulseColors.darkTextTertiary,
    textMuted: DevPulseColors.darkTextMuted,
    textDim: DevPulseColors.darkTextDim,
    textGhost: DevPulseColors.darkTextGhost,
    textFaint: DevPulseColors.darkTextFaint,
    textInvisible: DevPulseColors.darkTextInvisible,
    homeIndicator: DevPulseColors.darkHomeIndicator,
    overlay: DevPulseColors.darkOverlay,
    overlayHeavy: DevPulseColors.darkOverlayHeavy,
    navActive: DevPulseColors.darkNavActive,
    navInactive: DevPulseColors.darkNavInactive,
    barInactive: DevPulseColors.darkBarInactive,
    ringTrack: DevPulseColors.darkRingTrack,
    gridEmpty: DevPulseColors.darkGridEmpty,
    cardShadow: [],
  );

  static const light = DevPulseTheme(
    bg: DevPulseColors.lightBg,
    surface: DevPulseColors.lightSurface,
    surfaceElevated: DevPulseColors.lightSurfaceElevated,
    nav: DevPulseColors.lightNav,
    border: DevPulseColors.lightBorder,
    borderSubtle: DevPulseColors.lightBorderSubtle,
    fill: DevPulseColors.lightFill,
    fill2: DevPulseColors.lightFill2,
    fill3: DevPulseColors.lightFill3,
    text: DevPulseColors.lightText,
    textSecondary: DevPulseColors.lightTextSecondary,
    textTertiary: DevPulseColors.lightTextTertiary,
    textMuted: DevPulseColors.lightTextMuted,
    textDim: DevPulseColors.lightTextDim,
    textGhost: DevPulseColors.lightTextGhost,
    textFaint: DevPulseColors.lightTextFaint,
    textInvisible: DevPulseColors.lightTextInvisible,
    homeIndicator: DevPulseColors.lightHomeIndicator,
    overlay: DevPulseColors.lightOverlay,
    overlayHeavy: DevPulseColors.lightOverlayHeavy,
    navActive: DevPulseColors.lightNavActive,
    navInactive: DevPulseColors.lightNavInactive,
    barInactive: DevPulseColors.lightBarInactive,
    ringTrack: DevPulseColors.lightRingTrack,
    gridEmpty: DevPulseColors.lightGridEmpty,
    cardShadow: DevPulseColors.lightCardShadow,
  );

  static ThemeData materialTheme(bool isDark) {
    final dpTheme = isDark ? dark : light;
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: dpTheme.bg,
      textTheme: GoogleFonts.soraTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: DevPulseColors.primary,
        onPrimary: Colors.white,
        secondary: dpTheme.surface,
        onSecondary: dpTheme.text,
        surface: dpTheme.surface,
        onSurface: dpTheme.text,
        error: DevPulseColors.danger,
        onError: Colors.white,
      ),
    );
  }
}

class AppTheme extends InheritedWidget {
  final DevPulseTheme dpTheme;

  const AppTheme({
    super.key,
    required this.dpTheme,
    required super.child,
  });

  static DevPulseTheme of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppTheme>();
    return widget?.dpTheme ?? DevPulseTheme.dark;
  }

  @override
  bool updateShouldNotify(AppTheme oldWidget) => dpTheme != oldWidget.dpTheme;
}
