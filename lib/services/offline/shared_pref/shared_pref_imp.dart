import 'dart:convert';

import 'package:impulse/services/offline/shared_pref/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

//TODO: replace singleto with DI
class ImpulseSharedPrefImpl implements ImpulseSharedPref {
  ImpulseSharedPrefImpl._();

  static const String _userShared = "user";
  static const String _themeMode = "theme";
  static const String _destinationLocation = "destination_location";
  static const String _rootFolderLocation = "root_folder_location";
  static const String _alwaysAcceptConnection = "always_accept_connection";
  static const String _allowBrowseFile = "allow_browse_file";
  static const String _receiverPortNumber = "receiver_port_number";

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
  Map<String, dynamic>? get getUserInfo {
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
  String? get getThemeMode => _getString(_themeMode);

  @override
  Future<void> setThemeMode(String theme) async {
    await _setString(key: _themeMode, value: theme);
  }

  @override
  String? get getDestinationLocation => _getString(_destinationLocation);

  @override
  String? get getRootFolderLocation => _getString(_rootFolderLocation);

  @override
  Future<void> setDestinationLocation(String location) async {
    await _setString(key: _destinationLocation, value: location);
  }

  @override
  Future<void> setRootFolderLocation(String location) async {
    await _setString(key: _rootFolderLocation, value: location);
  }

  ////

  @override
  bool? get getAlwaysAcceptConnection => _getBool(_alwaysAcceptConnection);

  @override
  Future<void> setAlwaysAcceptConnection(bool alwaysAcceptConnection) async {
    await _setBool(key: _alwaysAcceptConnection, value: alwaysAcceptConnection);
  }

  @override
  bool? get getAllowBrowseFile => _getBool(_allowBrowseFile);

  @override
  Future<void> setAllowBrowseFile(bool allowBrowseFile) async {
    await _setBool(key: _allowBrowseFile, value: allowBrowseFile);
  }

  @override
  int? get getReceiverPortNumber => _getInt(_receiverPortNumber);

  @override
  Future<void> setReceiverPortNumber(int receiverPortNumber) async {
    await _setInt(key: _receiverPortNumber, value: receiverPortNumber);
  }

  Future<void> _setString({required String key, required String value}) async {
    // ignore: no_leading_underscores_for_local_identifiers
    final _value = json.encode(value);
    await _preferences.setString(key, _value);
    _preferences.reload();
  }

  String? _getString(String key) {
    final value = _preferences.getString(key);
    if (value != null) return json.decode(value);
    return null;
  }

  Future<void> _setBool({required String key, required bool value}) async {
    await _preferences.setBool(key, value);
    _preferences.reload();
  }

  bool? _getBool(String key) {
    final value = _preferences.getBool(key);
    if (value != null) return value;
    return null;
  }

  Future<void> _setInt({required String key, required int value}) async {
    await _preferences.setInt(key, value);
    _preferences.reload();
  }

  int? _getInt(String key) {
    final value = _preferences.getInt(key);
    if (value != null) return value;
    return null;
  }
}
