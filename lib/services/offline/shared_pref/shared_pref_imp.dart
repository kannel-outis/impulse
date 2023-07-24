import 'dart:convert';

import 'package:impulse/services/offline/shared_pref/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImpulseSharedPrefImpl implements ImpulseSharedPref {
  final SharedPreferences _preferences;

  ImpulseSharedPrefImpl(this._preferences);

  static const String _userShared = "user";

  @override
  Map<String, dynamic>? getUserInfo() {
    final value = _preferences.getString(_userShared);
    if (value != null) return json.decode(value);
    return null;
  }

  @override
  Future<bool> saveUserInfo(Map<String, dynamic> userMap) async {
    final value = json.encode(userMap);
    return await _preferences.setString(_userShared, value);
  }
}
