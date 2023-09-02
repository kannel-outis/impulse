import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse/services/services.dart';

final connectedUserPreviousSessionStateProvider = StateNotifierProvider<
    ConnectedUserPreviousSessionState,
    (Session session, HiveSession hiveUser)?>(
  (ref) => ConnectedUserPreviousSessionState(),
);

class ConnectedUserPreviousSessionState
    extends StateNotifier<(Session, HiveSession)?> {
  ConnectedUserPreviousSessionState() : super(null);

  bool _hasSetNewPrevSessison = false;

  bool get hasSetNewPrevSession => _hasSetNewPrevSessison;

  void hasSetNewPrev() {
    ///set once on a single session,
    _hasSetNewPrevSessison = true;
  }

  void setUserPrevSession(Session session, HiveSession user) {
    state = (session, user);
  }

  void clear() {
    state = null;
  }
}
