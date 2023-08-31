import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/models/server_info.dart';

///The [ConnectedUserState] is the state of any connected user to either the client--receiver or the host--sender
///
///
///Receiver side
///so when this receiver scans and selects the sender it wants to connect to, the [ConnectedUserState] state notifier handles
///the [ServerInfo] of that selected sender upon approval from that sender.
///
///
///Sender side
///when a receiver requests to connect to this Sender and it accepts, the [ConnectedUserState] state notifier handles the [ServerInfo]
///sent by the receiver.
///although, on the Sender side, the [ConnectedUserState] stores the receiver's [ServerInfo] for a few seconds (10 sec, the max amount of time the request is valid for)
///before any response from this Sender just for the purpose of showing this Sender who wants to connect with it (particularly the name).
///if the request is declined, The stored [ServerInfo] id discarded.
///
///
///
///
final connectUserStateProvider =
    StateNotifierProvider<ConnectedUserState, ServerInfo?>((ref) {
  final connectionStateController = ref.read(connectionStateProvider.notifier);
  return ConnectedUserState(null, connectionStateController);
});

class ConnectedUserState extends StateNotifier<ServerInfo?> {
  final ConnectionStateProvider connectionStateController;
  ConnectedUserState(super.state, this.connectionStateController);

  void setUserState(ServerInfo? info,
      {bool fling = false, bool disconnected = false}) {
    state = info;
    if (state != null && fling == false) {
      connectionStateController.setState(ConnectionState.connected);
    } else if (state != null && fling) {
      connectionStateController.setState(ConnectionState.fling);
    } else if (state == null) {
      connectionStateController.setState(ConnectionState.notConnected);
    } else if (disconnected && state == null) {
      connectionStateController.setState(ConnectionState.disconnected);
    }
  }
}
