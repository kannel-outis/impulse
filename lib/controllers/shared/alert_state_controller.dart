import 'package:flutter_riverpod/flutter_riverpod.dart';

final alertStateNotifier =
    StateNotifierProvider<AlertState, ({bool alertResult})>(
  (ref) => AlertState((alertResult: false)),
);

class AlertState extends StateNotifier<({bool alertResult})> {
  AlertState(super.state);

  // void shouldShowAlert(bool newState) {
  //   state = (alertResult: state.alertResult, showShouldAlert: newState);
  // }

  void alertResult(bool alertResult) {
    state = (alertResult: alertResult);
  }
}
