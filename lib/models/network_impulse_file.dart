import 'package:impulse/models/models.dart';
import 'package:impulse_utils/impulse_utils.dart';

class NetworkImpulseFileEntity extends FileSize {
  final bool isFolder;
  final String name;
  final DateTime modified;
  //The home server of this item
  final ServerInfo serverInfo;
  final String path;

  NetworkImpulseFileEntity({
    required this.isFolder,
    required this.name,
    int size = 0,
    required this.modified,
    required this.serverInfo,
    required this.path,
  }) : super(size);

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
      "modified": modified.toString(),
      "path": path,
      "serverInfo": serverInfo.toMap(),
    };
  }

  Uri get fileUri => Uri.parse(isFolder ? _folderDir : _filePath);

  String get _filePath =>
      "http://${serverInfo.ipAddress}:${serverInfo.port}/download?file=$path";

  String get _folderDir =>
      "http://${serverInfo.ipAddress}:${serverInfo.port}/download?folder=$path";
}
