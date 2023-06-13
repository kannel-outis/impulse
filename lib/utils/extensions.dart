import 'dart:math';

extension RandomItem<T> on List<T> {
  T get random {
    final range = length;
    final random = Random().nextInt(range);
    return this[random.abs()];
  }
}
