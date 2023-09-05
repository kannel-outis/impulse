import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/main.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse/services/services.dart';
import 'package:impulse_utils/impulse_utils.dart';
import 'package:path_provider/path_provider.dart';

class Configurations {
  Configurations._();

  static Configurations? _instance;

  static Configurations get instance {
    if (_instance == null) return _instance = Configurations._();
    return _instance!;
  }

  Directory? impulseDir;

  FileManager get fileManager => FileManager.instance;

  ImpulseUtils get impulseUtils => ImpulseUtils();
  final _impulsePath =
      "${Platform.pathSeparator}impulse files${Platform.pathSeparator}";

  Future<void> _loadPaths() async {
    if (_destinationLocation != null) {
      impulseDir = await Directory(
              "$_destinationLocation${Platform.pathSeparator}impulse files${Platform.pathSeparator}")
          .create();
      return;
    }
    final applicationDocumentDir = await getApplicationDocumentsDirectory();
    if (Platform.isAndroid) {
      await fileManager.getRootPaths(true);
      impulseDir = await Directory(
              "${fileManager.rootPath.where((element) => element.contains("emulated")).toList().first}impulse files${Platform.pathSeparator}")
          .create();
      return;
    }
    impulseDir =
        await Directory("${applicationDocumentDir.path}$_impulsePath").create();
  }

  Future<void> _loadHiveInit() async {
    await HiveInit.init();
  }

  ImpulseSharedPref get localPref => ImpulseSharedPrefImpl.instance;

  User? _user;

  //for first start
  User? get user => loadUser();

  User? loadUser() {
    if (_user != null) return _user;
    if (localPref.getUserInfo != null) {
      return _user = User.fromMap(localPref.getUserInfo!);
    } else {
      return null;
    }
  }

  Future<void> saveUserInfo(Map<String, dynamic> user) async {
    await localPref.saveUserInfo(user);
    _user = User.fromMap(user);
  }

  //Theme

  ThemeMode? _themeMode;
  ThemeMode? get themeMode => _themeMode;

  void loadTheme() {
    _themeMode = localPref.getThemeMode?.toThemeMode;
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await localPref.setThemeMode(themeMode.name);
    _themeMode = themeMode;
  }

  //Root Folder Location for desktop

  String? _rootFolderLocation;
  String? get rootFolderLocation => _rootFolderLocation;

  void loadRootFolderLocation() {
    _rootFolderLocation = localPref.getRootFolderLocation;
  }

  Future<void> setRootFolderLocation(String location) async {
    await localPref.setRootFolderLocation(location);
    _rootFolderLocation = location;
  }

  //Destination Location

  String? _destinationLocation;
  String? get destinationLocation => _destinationLocation;

  void loadDestinationLocation() {
    _destinationLocation ??= localPref.getDestinationLocation;
  }

  Future<void> setDestinationLocation(String location) async {
    await localPref.setDestinationLocation(location);
    impulseDir = await Directory("$location$_impulsePath").create();

    _destinationLocation = location;
  }

  //Always Accept Connection
  bool? _alwaysAcceptConnection;
  bool get alwaysAcceptConnection => _alwaysAcceptConnection ?? false;

  void loadAlwaysAcceptConnection() {
    _alwaysAcceptConnection ??= localPref.getAlwaysAcceptConnection;
  }

  Future<void> setAlwaysAcceptConnection(bool alwaysAccept) async {
    await localPref.setAlwaysAcceptConnection(alwaysAccept);
    _alwaysAcceptConnection = alwaysAccept;
  }

  //Allow to browse file
  bool? _allowToBrowseFile;
  bool get allowToBrowseFile => _allowToBrowseFile ?? false;

  void loadAllowToBrowseFile() {
    _allowToBrowseFile = localPref.getAllowBrowseFile;
  }

  Future<void> setAllowToBrowseFile(bool allowToBrowseFile) async {
    await localPref.setAllowBrowseFile(allowToBrowseFile);
    _allowToBrowseFile = allowToBrowseFile;
  }

  //Receiver Port Number
  int? _receiverPortNumber;
  int get receiverPortNumber => _receiverPortNumber ?? Constants.DEFAULT_PORT_2;

  void loadReceiverPortNumber() {
    _receiverPortNumber = localPref.getReceiverPortNumber;
  }

  Future<void> setReceiverPortNumber(int receiverPortNumber) async {
    await localPref.setReceiverPortNumber(receiverPortNumber);
    _receiverPortNumber = receiverPortNumber;
  }

  //Load all

  Future<void> loadAllInit() async {
    await ImpulseSharedPrefImpl.instance.loadInstance();
    loadUser();
    if (_user == null) return;

    await _loadHiveInit();
    await _loadPaths();
    loadTheme();
    loadRootFolderLocation();
    loadDestinationLocation();
    loadAlwaysAcceptConnection();
    loadAllowToBrowseFile();
    loadReceiverPortNumber();

    // composition = await AssetLottie("assets/lottie/waiting.json").load();
  }

  static Impulse of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<Impulse>()!;
}
