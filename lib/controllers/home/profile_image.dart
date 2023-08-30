import 'package:impulse/app/app.dart';
import 'package:riverpod/riverpod.dart';

final profileImageProvider =
    StateNotifierProvider<ProfileImageController, String?>((ref) {
  return ProfileImageController(Configurations.instance.user?.displayImage);
});

class ProfileImageController extends StateNotifier<String?> {
  ProfileImageController(super.value);

  void onChanged(String value) {
    state = value;
  }
}
