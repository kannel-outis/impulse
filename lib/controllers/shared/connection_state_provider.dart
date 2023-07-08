import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';

final connectionStateProvider =
    StateNotifierProvider<ConnectionStateProvider, ConnectionState>(
        (ref) => ConnectionStateProvider(ConnectionState.notConnected));

class ConnectionStateProvider extends StateNotifier<ConnectionState> {
  ConnectionStateProvider(super.state);

  void setState(ConnectionState state) {
    this.state = state;
  }
}
