import 'package:flutter_riverpod/flutter_riverpod.dart';

final alertStateNotifier =
    StateNotifierProvider<AlertState, bool>((ref) => AlertState());

class AlertState extends StateNotifier<bool> {
  AlertState() : super(false);

  void updateState(bool newState) {
    state = newState;
  }
}
