import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/services/services.dart';

final connectedUserPreviousSessionStateProvider = StateNotifierProvider<
    ConnectedUserPreviousSessionState,
    ({HiveSession prevSession, HiveSession nextSession})?>(
  (ref) => ConnectedUserPreviousSessionState(),
);

class ConnectedUserPreviousSessionState extends StateNotifier<
    ({HiveSession prevSession, HiveSession nextSession})?> {
  ConnectedUserPreviousSessionState() : super(null);

  bool _hasSetNewPrevSessison = false;

  bool get hasSetNewPrevSession => _hasSetNewPrevSessison;

  void hasSetNewPrev() {
    ///set once on a single session,
    _hasSetNewPrevSessison = true;
  }

  void setUserPrevSession(HiveSession prevSession, HiveSession nextSession) {
    state = (prevSession: prevSession, nextSession: nextSession);
  }

  void clear() {
    state = null;
  }
}
