import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String name;
  final String id;
  final String deviceName;
  final String deviceOsVersion;
  // final bool isHost;
  final int? port;
  final String? ipAddress;
  final String displayImage;

  const User({
    required this.name,
    required this.id,
    this.deviceName = "unknown",
    this.deviceOsVersion = "unknown",
    required this.displayImage,
    this.ipAddress,
    this.port,
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

  User copyWith({
    String? ipAddress,
    int? port,
  }) {
    return User(
      name: name,
      id: id,
      displayImage: displayImage,
      deviceName: deviceName,
      deviceOsVersion: deviceOsVersion,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
    );
  }

  String get _flingUrl {
    return "http://$ipAddress:$port/download?file=$displayImage";
  }

  Map<String, dynamic> toFlingMap() {
    return {
      "name": name,
      "id": id,
      "deviceName": deviceName,
      "deviceOsVersion": deviceOsVersion,
      "displayImage": _flingUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map["name"] as String,
      id: map["id"] as String,
      displayImage: map["displayImage"] as String,
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
