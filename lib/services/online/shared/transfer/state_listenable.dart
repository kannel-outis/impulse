
import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';

mixin class StateListenable {
  final List<OnStateChange> _listeners = [];

  void addListener(OnStateChange onStateChange) {
    if (_listeners.contains(onStateChange)) return;
    _listeners.add(onStateChange);
  }

  void removeListener(OnStateChange onStateChange) {
    if (_listeners.contains(onStateChange)) {
      _listeners.remove(onStateChange);
    }
  }

  void notifyListeners(
    int received,
    int totalSize,
    File? file,
    String? reason,
    IState state,
  ) {
    for (final listener in _listeners) {
      listener.call(received, totalSize, file, reason, state);
    }
  }

  void dispose() {
    _listeners.clear();
  }
}
