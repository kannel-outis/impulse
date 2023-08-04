import 'dart:io';

class Path {
  final String location;

  const Path({
    required this.location,
  });

  String get locationDecode => Uri.decodeComponent(location);
  String get path => locationDecode.split("/folder/files/").last;
  String get name {
    final ss = path.split(Platform.pathSeparator);
    ss.removeWhere((s) => s == "");
    return ss.last;
  }
}
