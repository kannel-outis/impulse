import 'dart:io';

class Path {
  final String location;

  const Path({
    required this.location,
  });

  String get locationDecode => Uri.decodeComponent(location);
  String get path => locationDecode.split("/folder/files/").last;
  String get name => path.split(Platform.pathSeparator).last;
}
