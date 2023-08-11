abstract class ImpulseSharedPref {
  Future<void> loadInstance();
  Future<bool> saveUserInfo(Map<String, dynamic> userMap);
  Map<String, dynamic>? getUserInfo();
}
