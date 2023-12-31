import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:vibration/vibration.dart';

final connectionStateProvider =
    StateNotifierProvider<ConnectionStateProvider, ConnectionState>((ref) {
  final genericRef = GenericProviderRef<Ref>(ref);

  return ConnectionStateProvider(
    ConnectionState.notConnected,
    () {
      if (!isDeskTop) {
        Vibration.hasCustomVibrationsSupport().then((value) {
          if (value != null && value) {
            Vibration.vibrate(duration: 300);
          } else {
            Vibration.vibrate();
          }
        });
      }
      share(genericRef, true);
    },
  );
});

class ConnectionStateProvider extends StateNotifier<ConnectionState> {
  final VoidCallback? onConnectionCallback;

  ConnectionStateProvider(super.state, [this.onConnectionCallback]);

  void setState(ConnectionState state) {
    this.state = state;
    if (state == ConnectionState.connected) {
      onConnectionCallback?.call();
    }
  }
}
