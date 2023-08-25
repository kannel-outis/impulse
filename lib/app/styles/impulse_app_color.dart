import 'package:flutter/material.dart';

class AppColors {
  const AppColors();
  final _accentColor1 = const Color(0xff343a40);
  final _accentColor2 = const Color(0xff363e45);
  final _primaryColor = const Color(0xff04a4e3);
  final _iconColor1 = const Color(0xffc4c9cf);
  final _iconColor2 = const Color(0xff04a4e3);
  final folderColor2 = const Color(0xfff7be3a);
  Color get _fontColor1 => _iconColor1;
  Color get _iconColor3 => fontColor2;
  final fontColor2 = const Color(0xff7e848b);
  ColorScheme get _scheme => ColorScheme(
      brightness: Brightness.dark,
      primary: _primaryColor,
      onPrimary: Colors.white,
      secondary: _primaryColor,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.red,
      background: _accentColor1,
      onBackground: _accentColor2,
      surface: _accentColor1,
      onSurface: _accentColor2,
      //icon color
      tertiary: _iconColor1,
      onTertiary: _iconColor2);

  ThemeData get theme {
    return ThemeData.from(
      colorScheme: _scheme, useMaterial3: true,
      //TODO: chnage to dynamic later
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: _fontColor1,
          ),
      // textTheme: _textTheme,
    );
  }
}
