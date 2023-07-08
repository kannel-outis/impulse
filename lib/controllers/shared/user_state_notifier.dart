import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';

final userProvider = StateNotifierProvider<UserStateNotifier, User>(
    (ref) => UserStateNotifier(User.undecided));

class UserStateNotifier extends StateNotifier<User> {
  UserStateNotifier(super.state);

  void setUserState(User state) {
    this.state = state;
  }
}
