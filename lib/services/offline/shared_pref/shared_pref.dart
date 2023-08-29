abstract class ImpulseSharedPref {
  Future<void> loadInstance();
  Future<bool> saveUserInfo(Map<String, dynamic> userMap);
  Map<String, dynamic>? get getUserInfo;
  Future<void> setThemeMode(String theme);
  String? get getThemeMode;
  Future<void> setDestinationLocation(String location);
  String? get getDestinationLocation;
  Future<void> setRootFolderLocation(String location);
  String? get getRootFolderLocation;
  Future<void> setAlwaysAcceptConnection(bool alwaysAcceptConnection);
  bool? get getAlwaysAcceptConnection;
  Future<void> setAllowBrowseFile(bool allowBrowseFile);
  bool? get getAllowBrowseFile;
}
