abstract class ImpulseSharedPref {
  Future<bool> saveUserInfo(Map<String, dynamic> userMap);
  Map<String, dynamic>? getUserInfo();
}
