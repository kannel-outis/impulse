import 'dart:math' as math;

extension RandomItem<T> on List<T> {
  T get random {
    final range = length;
    final random = math.Random().nextInt(range);
    return this[random.abs()];
  }
}
