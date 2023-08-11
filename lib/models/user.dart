import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String name;
  final String id;
  final String deviceName;
  final String deviceOsVersion;
  // final bool isHost;
  // final String? ipAddress;
  final Uint8List displayImage;

  const User({
    required this.name,
    required this.id,
    this.deviceName = "unknown",
    this.deviceOsVersion = "unknown",
    required this.displayImage,
    // this.ipAddress,
    // this.isHost = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "id": id,
      "deviceName": deviceName,
      "deviceOsVersion": deviceOsVersion,
      "displayImage": displayImage,
      // "isHost": isHost,
      // "ipAddress": ipAddress,
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
      // isHost: map["isHost"] as bool,
      // ipAddress: map["ipAddress"] as String?,
    );
  }

  @override
  List<Object?> get props => [
        deviceName,
        deviceOsVersion,
        // ipAddress,
        id,
        name,
        // isHost,
      ];
}
