import 'package:flutter/material.dart';

class AppColors {
  const AppColors();
  final accentColor1 = const Color(0xff343a40);
  final accentColor2 = const Color(0xff363e45);
  final secondaryColor = const Color(0xff04a4e3);
  final iconColor1 = const Color(0xffc4c9cf);
  final iconColor2 = const Color(0xff04a4e3);
  final folderColor2 = const Color(0xfff7be3a);
  Color get fontColor1 => iconColor1;
  Color get iconColor3 => fontColor2;
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
        // background: accentColor1,
        onBackground: Colors.white,
        surface: accentColor1,
        onSurface: Colors.white,
      );

  ThemeData get theme {
    return ThemeData.from(
      colorScheme: _scheme, useMaterial3: true,
      //TODO: chnage to dynamic later
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: fontColor1,
          ),
      // textTheme: _textTheme,
    );
  }
}
