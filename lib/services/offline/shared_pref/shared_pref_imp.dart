import 'dart:convert';

import 'package:impulse/services/offline/shared_pref/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImpulseSharedPrefImpl implements ImpulseSharedPref {
  ImpulseSharedPrefImpl._();

  static const String _userShared = "user";
  static const String _themeMode = "theme";

  static late final SharedPreferences _preferences;

  static ImpulseSharedPref? _instance;
  static ImpulseSharedPref get instance {
    _instance ??= ImpulseSharedPrefImpl._();
    return _instance!;
  }

  @override
  Future<void> loadInstance() async {
    _preferences = await SharedPreferences.getInstance();
  }

  @override
  Map<String, dynamic>? getUserInfo() {
    final value = _preferences.getString(_userShared);
    if (value != null) return json.decode(value);
    return null;
  }

  @override
  Future<bool> saveUserInfo(Map<String, dynamic> userMap) async {
    final value = json.encode(userMap);
    final result = await _preferences.setString(_userShared, value);
    _preferences.reload();
    return result;
  }

  @override
  String? getThemeMode() {
    final value = _preferences.getString(_themeMode);
    if (value != null) return json.decode(value);
    return null;
  }

  @override
  Future<void> setThemeMode(String theme) async {
    final value = json.encode(theme);
    await _preferences.setString(_themeMode, value);
    _preferences.reload();
  }
}
