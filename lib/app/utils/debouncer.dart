import 'dart:async';

import 'package:flutter/material.dart';

class Debouncer {
  final Duration duration;

  Debouncer({
    required this.duration,
  });

  Timer? _timer;

  void cancel() {
    _timer?.cancel();
  }

  void debounce([VoidCallback? function]) {
    if (_timer == null || !_timer!.isActive) {
      _timer?.cancel();
      _timer = Timer(duration, function ?? () {});
    }
  }
}
