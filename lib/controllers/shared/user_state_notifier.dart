import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';

final userProvider = StateNotifierProvider<UserStateNotifier, UserType>(
    (ref) => UserStateNotifier(UserType.undecided));

class UserStateNotifier extends StateNotifier<UserType> {
  UserStateNotifier(super.state);

  void setUserState(UserType state) {
    this.state = state;
  }
}
