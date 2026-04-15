import 'package:flutter/material.dart';

class AppThemeData {
  static const _lightFillColor = Colors.black87;
  static const _darkFillColor = Color(0xE6DCDCDC);

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  static ThemeData lightThemeData =
      themeData(lightColorScheme, _lightFocusColor);
  static ThemeData darkThemeData = themeData(darkColorScheme, _darkFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: _textTheme.apply(bodyColor: colorScheme.onPrimary, displayColor: colorScheme.onPrimary),
      primaryColor: const Color(0xFF030303),
      appBarTheme: AppBarTheme(
        color: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      canvasColor: colorScheme.surface,
      scaffoldBackgroundColor: colorScheme.surface,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: focusColor,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.alphaBlend(
          _lightFillColor.withOpacity(0.80),
          _darkFillColor,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.brightness == Brightness.light
              ? Colors.white
              : colorScheme.onPrimary,
        ),
      ),
    );
  }

  static const ColorScheme lightColorScheme = ColorScheme(    
    primary: Color(0xFF000000),
    secondary: Color(0xFFEFF3F3),
    surface: Color.fromARGB(255, 255, 255, 255),
    secondaryContainer: Color.fromARGB(255, 117, 117, 117),
    error: _lightFillColor,
    onError: _lightFillColor,
    onPrimary: _lightFillColor,
    onSecondary: Color(0xFF322942),
    onSurface: Color(0xFF241E30),
    brightness: Brightness.light,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    primary: Color(0xFF18FAE2),
    secondary: Color(0xFF1F797C),
    surface: Color.fromARGB(255, 58, 48, 74),
    error: _darkFillColor,
    onError: _darkFillColor,
    onPrimary: _darkFillColor,
    onSecondary: _darkFillColor,
    onSurface: _darkFillColor,
    brightness: Brightness.dark,
  );

  static const _bold = FontWeight.w700;

  static final TextTheme _textTheme = TextTheme(
    headlineLarge: TextStyle(fontWeight: _bold, fontSize: 20.0)
  );
}

heavyBoxShadow() {
  return const BoxShadow(
      color: Color(0xB3000000), offset: Offset(0, 4), blurRadius: 10.0);
}

commonBoxShadow() {
  return const BoxShadow(
      color: Colors.black26, offset: Offset(0, 2), blurRadius: 10.0);
}

slightBoxShadow() {
  return const BoxShadow(
      color: Colors.black26, offset: Offset(0, 1), blurRadius: 5.0);
}

minorBoxShadow() {
  return const BoxShadow(
      color: Colors.black12, offset: Offset(1, 1), blurRadius: 1.0);
}

commonToolbarOptions() {
  return const ToolbarOptions(
      copy: true, selectAll: true, cut: false, paste: false);
}
