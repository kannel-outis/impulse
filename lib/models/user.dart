import 'dart:typed_data';

class User {
  final String name;
  final String id;
  final String deviceName;
  final String deviceOsVersion;
  final bool isHost;
  final Uint8List displayImage;

  User({
    required this.name,
    required this.id,
    this.deviceName = "unknown",
    this.deviceOsVersion = "unknown",
    required this.displayImage,
    this.isHost = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "id": id,
      "deviceName": deviceName,
      "deviceOsVersion": deviceOsVersion,
      "displayImage": displayImage,
      "isHost": isHost,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map["name"] as String,
      id: map["id"] as String,
      displayImage: Uint8List.fromList(
        List<int>.from(map["displayImage"]),
      ),
      deviceName: map["deviceName"] as String,
      deviceOsVersion: map["deviceOsVersion"] as String,
      isHost: map["isHost"] as bool,
    );
  }
}
