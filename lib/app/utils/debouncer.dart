import 'dart:async';

import 'package:flutter/material.dart';

class Debouncer {
  final Duration duration;
  final VoidCallback function;

  Debouncer({
    required this.duration,
    required this.function,
  });

  Timer? _timer;

  void cancel() {
    _timer?.cancel();
  }

  void debounce([VoidCallback? function]) {
    if (_timer == null || !_timer!.isActive) {
      _timer?.cancel();
      _timer = Timer(duration, function ?? this.function);
    }
  }
}
