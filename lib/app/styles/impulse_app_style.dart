// ignore_for_file: library_private_types_in_public_api

/// A copy of the font style used in the flutter wonderous app by the gskinnerTeam
/// [https://github.com/gskinnerTeam/flutter-wonderous-app/blob/main/lib/styles/styles.dart]

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

@immutable
class AppStyle {
  AppStyle({Size? screenSize}) {
    if (screenSize == null) {
      scale = 1;
      return;
    }
    _screenSize = screenSize;
    final shortestSide = screenSize.shortestSide;
    const tabletXl = 1000;
    const tabletLg = 800;
    const tabletSm = 600;
    const phoneLg = 400;
    if (shortestSide > tabletXl) {
      scale = 1;
      // scale = 1.25;
    } else if (shortestSide > tabletLg) {
      // scale = 1.15;
      scale = 1;
    } else if (shortestSide > tabletSm) {
      scale = 1;
    } else if (shortestSide > phoneLg) {
      scale = .9; // phone
    } else {
      scale = .85; // small phone
    }
    //debugPrint('screenSize=$screenSize, scale=$scale');
  }

  late final Size _screenSize;

  final tabletXl = 1000;
  final tabletLg = 800;
  final tabletSm = 600;
  final phoneLg = 400;

  Size get screenSize => _screenSize;

  bool get isNotPhone => _screenSize.width > tabletLg;

  late final double scale;

  /// The current theme colors for the app
  final AppColors colors = const AppColors();

  /// Rounded edge corner radii
  late final _Corners corners = _Corners();

  late final _Shadows shadows = _Shadows();

  /// Padding and margin values
  late final _Insets insets = _Insets(scale);

  /// Text styles
  late final _Text text = _Text(scale, colors);

  /// Animation Durations
  final _Times times = _Times();

  /// Shared sizes
  late final _Sizes sizes = _Sizes();

  /// Curves
  late final _Curves curves = _Curves();

  late final constraints = _Constraints(sizes, _screenSize);
}

@immutable
class _Text {
  final AppColors colors;
  _Text(this._scale, this.colors);
  final double _scale;

  final Map<String, TextStyle> _titleFonts = {
    'en': const TextStyle(fontFamily: 'JosefinSans'),
  };

  final Map<String, TextStyle> _monoTitleFonts = {
    'en': const TextStyle(fontFamily: 'JosefinSans'),
  };

  final Map<String, TextStyle> _quoteFonts = {
    'en': const TextStyle(fontFamily: 'JosefinSans'),
    'zh': const TextStyle(fontFamily: 'MaShanZheng'),
  };

  final Map<String, TextStyle> _impulseTitleFonts = {
    'en': const TextStyle(fontFamily: 'JosefinSans'),
  };

  final Map<String, TextStyle> _contentFonts = {
    'en': const TextStyle(fontFamily: 'JosefinSans', fontFeatures: [
      FontFeature.enable('kern'),
    ]),
  };

  TextStyle _getFontForLocale(Map<String, TextStyle> fonts) {
    return fonts["en"]!;
    // if (localeLogic.isLoaded) {
    //   return fonts.entries
    //       .firstWhere((x) => x.key == $strings.localeName,
    //           orElse: () => fonts.entries.first)
    //       .value;
    // } else {
    //   return fonts.entries.first.value;
    // }
  }

  TextStyle get titleFont => _getFontForLocale(_titleFonts);
  TextStyle get quoteFont => _getFontForLocale(_quoteFonts);
  TextStyle get impulseTitleFont => _getFontForLocale(_impulseTitleFonts);
  TextStyle get contentFont => _getFontForLocale(_contentFonts);
  TextStyle get monoTitleFont => _getFontForLocale(_monoTitleFonts);

  late final TextStyle dropCase =
      _createFont(quoteFont, sizePx: 56, heightPx: 20);

  late final TextStyle impulseTitle =
      _createFont(impulseTitleFont, sizePx: 64, heightPx: 56);

  late final TextStyle h1 = _createFont(titleFont, sizePx: 64, heightPx: 62);
  late final TextStyle h2 = _createFont(titleFont, sizePx: 32, heightPx: 46);
  late final TextStyle h3 =
      _createFont(titleFont, sizePx: 20, heightPx: 32, weight: FontWeight.w600);
  late final TextStyle h4 = _createFont(contentFont,
      sizePx: 14, heightPx: 23, spacingPc: 5, weight: FontWeight.w600);

  late final TextStyle title1 =
      _createFont(titleFont, sizePx: 16, heightPx: 26, spacingPc: 5);
  late final TextStyle title2 =
      _createFont(titleFont, sizePx: 14, heightPx: 16.38);

  late final TextStyle body =
      _createFont(contentFont, sizePx: 16, heightPx: 26);
  late final TextStyle bodyBold = _createFont(contentFont,
      sizePx: 16, heightPx: 26, weight: FontWeight.w600);
  late final TextStyle bodySmall =
      _createFont(contentFont, sizePx: 12, heightPx: 23);
  late final TextStyle bodySmallBold = _createFont(contentFont,
      sizePx: 12, heightPx: 23, weight: FontWeight.w600);

  late final TextStyle quote1 = _createFont(quoteFont,
      sizePx: 32, heightPx: 40, weight: FontWeight.w600, spacingPc: -3);
  late final TextStyle quote2 =
      _createFont(quoteFont, sizePx: 21, heightPx: 32, weight: FontWeight.w400);
  late final TextStyle quote2Sub =
      _createFont(body, sizePx: 16, heightPx: 40, weight: FontWeight.w400);

  late final TextStyle caption = _createFont(contentFont,
          sizePx: 14, heightPx: 20, weight: FontWeight.w500)
      .copyWith(fontStyle: FontStyle.italic);

  late final TextStyle callout = _createFont(contentFont,
          sizePx: 16, heightPx: 26, weight: FontWeight.w600)
      .copyWith(fontStyle: FontStyle.italic);
  late final TextStyle btn = _createFont(contentFont,
      sizePx: 14, weight: FontWeight.w500, spacingPc: 2, heightPx: 14);

  TextStyle _createFont(TextStyle style,
      {required double sizePx,
      double? heightPx,
      double? spacingPc,
      FontWeight? weight,
      Color? color}) {
    sizePx *= _scale;
    if (heightPx != null) {
      heightPx *= _scale;
    }
    return style.copyWith(
        fontSize: sizePx,
        color: color,
        // color: color ?? colors.fontColor1,
        height: heightPx != null ? (heightPx / sizePx) : style.height,
        letterSpacing:
            spacingPc != null ? sizePx * spacingPc * 0.01 : style.letterSpacing,
        fontWeight: weight);
  }
}

@immutable
class _Times {
  final Duration fast = const Duration(milliseconds: 300);
  final Duration med = const Duration(milliseconds: 600);
  final Duration slow = const Duration(milliseconds: 900);
  final Duration xSlow = const Duration(seconds: 5);
  final Duration pageTransition = const Duration(milliseconds: 200);
}

@immutable
class _Corners {
  late final double sm = 4;
  late final double md = 8;
  late final double lg = 32;
  late final double xxlg = 200;
}

class _Sizes {
  double get maxContentWidth1 => 800;
  double get maxContentWidth2 => 600;
  double get maxContentWidth3 => 500;

  double get maxContentHeight1 => 300;
  double get maxContentHeight2 => 500;
  double get maxContentHeight3 => 700;

  /////
  final Size minAppSize = const Size(380, 250);
  Size get modalBoxSize => Size(maxContentWidth1, maxContentHeight1);
  Size get defaultAppBarSize => const Size.fromHeight(60);

  ///icons sizes
  double get prefixIconSize => 50.scale;
  double get xxSmallIconSize => 10.scale;
  double get xSmallIconSize => 20.scale;
  double get smallIconSize2 => 30.scale;
  double get smallIconSize => 40.scale;
  double get mediumIconSize => 60.scale;
  double get largeIconSize => 80.scale;
  double get xLargeIconSize => 100.scale;
  double get xxLargeIconSize => 150.scale;
}

@immutable
class _Insets {
  _Insets(this._scale);
  final double _scale;

  late final double xxs = 4 * _scale;
  late final double xs = 8 * _scale;
  late final double sm = 16 * _scale;
  late final double md = 24 * _scale;
  late final double lg = 32 * _scale;
  late final double xl = 48 * _scale;
  late final double xxl = 56 * _scale;
  late final double offset = 80 * _scale;
}

@immutable
class _Shadows {
  final boxShadowSmall = [
    BoxShadow(
      blurRadius: 5,
      color: Colors.black.withOpacity(.2),
      blurStyle: BlurStyle.outer,
    ),
  ];
  final textSoft = [
    Shadow(
        color: Colors.black.withOpacity(.25),
        offset: const Offset(0, 2),
        blurRadius: 4),
  ];
  final text = [
    Shadow(
        color: Colors.black.withOpacity(.6),
        offset: const Offset(0, 2),
        blurRadius: 2),
  ];
  final textStrong = [
    Shadow(
        color: Colors.black.withOpacity(.6),
        offset: const Offset(0, 4),
        blurRadius: 6),
  ];
}

@immutable
class _Curves {
  final defaultCurve = Curves.easeOutBack;
}

@immutable
class _Constraints {
  final _Sizes _sizes;
  final Size screenSize;

  const _Constraints(this._sizes, this.screenSize);
  BoxConstraints get modalConstraints => BoxConstraints(
        maxWidth: _sizes.maxContentWidth1,
        // maxHeight: _sizes.maxContentHeight1,
        maxHeight:
            screenSize.width < 420 ? 200 : (screenSize.height / 100) * 30,
      );
}
