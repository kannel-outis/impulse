import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse/services/services.dart';

final connectedUserPreviousSessionStateProvider = StateNotifierProvider<
    ConnectedUserPreviousSessionState, (Session session, HiveUser hiveUser)?>(
  (ref) => ConnectedUserPreviousSessionState(),
);

class ConnectedUserPreviousSessionState
    extends StateNotifier<(Session, HiveUser)?> {
  ConnectedUserPreviousSessionState() : super(null);

  void setUserPrevSession(Session session, HiveUser user) {
    state = (session, user);
  }

  void clear() {
    state = null;
  }
}
