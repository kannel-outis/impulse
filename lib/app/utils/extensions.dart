import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:impulse_utils/impulse_utils.dart';

import 'globals.dart';

extension RandomItem<T> on List<T> {
  T get random {
    final range = length;
    final random = Random().nextInt(range);
    return this[random.abs()];
  }
}

extension Scale on num {
  double get scale {
    return (this * $styles.scale);
  }
}

extension Insets on double {
  EdgeInsets get insets {
    return EdgeInsets.all(this);
  }

  EdgeInsets get insetsLeft {
    return EdgeInsets.only(left: this);
  }

  EdgeInsets get insetsRight {
    return EdgeInsets.only(right: this);
  }

  EdgeInsets get insetsTop {
    return EdgeInsets.only(top: this);
  }

  EdgeInsets get insetsBottom {
    return EdgeInsets.only(bottom: this);
  }
}

extension SymmetricInsets on (double, double) {
  EdgeInsets get insets {
    return EdgeInsets.symmetric(horizontal: this.$1, vertical: this.$2);
  }

  EdgeInsets get insetsTopBottom {
    return EdgeInsets.only(top: this.$1, bottom: this.$2);
  }

  EdgeInsets get insetsLeftRight {
    return EdgeInsets.only(left: this.$1, right: this.$2);
  }
}

extension FileType on ImpulseFileType {
  bool get isImage {
    return this == ImpulseFileType.jpeg ||
        this == ImpulseFileType.jpg ||
        this == ImpulseFileType.png;
  }

  bool get isVideo {
    return this == ImpulseFileType.mov || this == ImpulseFileType.mp4;
  }
}

extension Cut on String {
  String get cutTimeDateString {
    final strings = split(":");
    strings.removeLast();
    return strings.join(":");
  }

  bool get isAsset {
    return contains("assets");
  }

  File get toFile {
    return File(this);
  }
}

extension Contains on Offset {
  bool contains(Offset outerOffset, double size) {
    final size1 = Size(size, size);
    final size2 = Size(size, size);

    final position1 = this;
    final position2 = outerOffset;

    return (position1.dx < position2.dx + size2.width &&
        position1.dx + size1.width > position2.dx &&
        position1.dy < position2.dy + size2.height &&
        position1.dy + size1.height > position2.dy);
  }
}
