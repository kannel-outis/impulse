import 'package:flutter/material.dart';

class AppColors {
  const AppColors();
  final accentColor1 = const Color(0xff363e45);
  final secondaryColor = const Color(0xff04a4e3);
  final iconColor1 = const Color(0xffc4c9cf);
  final iconColor2 = const Color(0xff04a4e3);
  // final fontColor1 =
  final fontColor2 = const Color(0xff7e848b);
  ColorScheme get _scheme => ColorScheme(
        brightness: Brightness.dark,
        primary: secondaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.red,
        background: accentColor1,
        onBackground: Colors.white,
        surface: accentColor1,
        onSurface: Colors.white,
      );

  ThemeData get theme => ThemeData.from(
        colorScheme: _scheme,
        // textTheme: _textTheme,
      );
}
