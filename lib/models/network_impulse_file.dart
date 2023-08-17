import 'package:impulse/models/models.dart';

class NetworkImpulseFileEntity {
  final bool isFolder;
  final String name;
  final int size;
  final DateTime modified;
  final ServerInfo serverInfo;
  final String path;

  const NetworkImpulseFileEntity({
    required this.isFolder,
    required this.name,
    this.size = 0,
    required this.modified,
    required this.serverInfo,
    required this.path,
  });

  factory NetworkImpulseFileEntity.fromMap(Map<String, dynamic> map) {
    return NetworkImpulseFileEntity(
      isFolder: map["isFolder"] as bool,
      name: map["name"] as String,
      modified: DateTime.parse(map["modified"]),
      serverInfo: ServerInfo.fromMap(map["serverInfo"] as Map<String, dynamic>),
      path: map["path"] as String,
      size: map["size"] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "isFolder": isFolder,
      "name": name,
      "size": size,
      "modified": modified,
      "path": isFolder ? _folderDir : _filePath,
      "serverInfo": serverInfo.toMap(),
    };
  }

  String get _filePath =>
      "http://${serverInfo.ipAddress}:${serverInfo.port}/download?file=$path";

  String get _folderDir =>
      "http://${serverInfo.ipAddress}:${serverInfo.port}/download?folder=$path";
}
