import 'dart:io';

class Path {
  final String location;
  String? altName;

  Path({
    required this.location,
    this.altName,
  });

  String get locationDecode => Uri.decodeComponent(location);
  String get path => locationDecode.split("/folder/files/").last;
  String get name {
    final ss = path.split(Platform.pathSeparator);
    ss.removeWhere((s) => s == "");
    return altName ?? ss.last;
  }
}
