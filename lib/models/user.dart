import 'dart:typed_data';

class User {
  final String name;
  final String id;
  final String deviceName;
  final String deviceOsVersion;
  final Uint8List displayImage;

  User({
    required this.name,
    required this.id,
    this.deviceName = "unknown",
    this.deviceOsVersion = "unknown",
    required this.displayImage,
  });
}
