import 'dart:math';

import 'package:flutter/material.dart';

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
