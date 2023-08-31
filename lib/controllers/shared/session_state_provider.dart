import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/models/models.dart';

final sessionStateProvider =
    StateNotifierProvider<SessionState, Session?>((ref) {
  return SessionState();
});

class SessionState extends StateNotifier<Session?> {
  SessionState() : super(null);

  void setSession(Session newSession) {
    state = newSession;
  }

  void cancelSession() {
    state = null;
  }
}
