import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';
import 'package:riverpod/riverpod.dart';

class MBps extends StateNotifier<(int mBps, Item? currentItem)> {
  MBps(super.state);

  DateTime _previouseReceivedTime = DateTime.now();
  int _previouseReceivedByte = 0;
  int previousMBps = 0;

  final Debouncer _debouncer =
      Debouncer(duration: const Duration(seconds: 1), function: () {});

  void mbps(now, received, totalSize, file, reason, state) {
    _debouncer.debounce(
      () => debouncedFunction(now, received, totalSize, file, reason, state),
    );
  }

  void cancelMbps() {
    _debouncer.cancel();
  }

  void debouncedFunction(
    DateTime now,
    int received,
    int totalSize,
    file,
    String reason,
    IState state,
  ) {
    final duration = now.difference(_previouseReceivedTime).inSeconds;
    final bytesPerInterval = (received - _previouseReceivedByte) ~/ duration;
    final mBps =
        bytesPerInterval.isNegative ? previousMBps : bytesPerInterval.toInt();
    this.state = (mBps, this.state.$2);
    previousMBps = mBps;

    // log(bytesPerInterval.toString());
    _previouseReceivedTime = now;
    _previouseReceivedByte = received;
  }
}
