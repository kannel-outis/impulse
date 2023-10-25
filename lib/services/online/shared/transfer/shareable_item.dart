import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';
import 'package:impulse_utils/impulse_utils.dart';
import 'package:uuid/uuid.dart';
part 'shareable_folder.dart';
part 'shareable_file.dart';

// ignore: must_be_immutable
abstract class ShareableItem extends UploaderItem {
  final String? altName;
  ShareableItem({
    required FileSystemEntity file,
    required String fileType,
    required int fileSize,
    required String id,
    (String, int)? homeDestination,
    this.altName,
    required String authorId,
  }) : super(
          id: id,
          fileSystemEntity: file,
          fileSize: fileSize,
          fileType: fileType,
          authorId: authorId,
          homeDestination: homeDestination,
          fileName: altName ?? file.path.split(Platform.pathSeparator).last,
        );

  factory ShareableItem.fromMap(Map<String, dynamic> map) {
    return ShareableItem.file(
      file: File(map["path"] as String),
      fileType: map["fileType"] as String,
      fileSize: map["fileSize"] as int,
      id: map["fileId"] as String,
      authorId: map["senderId"] as String,
      altName: map["altName"] as String?,
      homeDestination: (
        map["homeDestination"]["ip"] as String,
        map["homeDestination"]["port"] as int
      ),
    );
  }

  factory ShareableItem.file({
    required File file,
    required String fileType,
    required int fileSize,
    required String id,
    (String, int)? homeDestination,
    String? altName,
    required String authorId,
  }) =>
      _ShareableFile(
        authorId: authorId,
        file: file,
        fileSize: fileSize,
        fileType: fileType,
        id: id,
        altName: altName,
        homeDestination: homeDestination,
      );

  factory ShareableItem.folder({
    required Directory dir,
    required String fileType,
    required int fileSize,
    required String id,
    (String, int)? homeDestination,
    String? altName,
    required String authorId,
  }) =>
      _ShareableFolder(
        dir: dir,
        authorId: authorId,
        fileSize: fileSize,
        fileType: fileType,
        id: id,
        altName: altName,
      );

  IState _state = IState.pending;

  int sentBytes = 0;

  ///should be called from the server
  void updateProgress(int received, int totalSize, IState state) {
    _state = state;
    sentBytes = received;
    notifyListeners(received, totalSize, fileSystemEntity, "", state);
  }

  @override
  int get proccessedBytes => sentBytes;

  @override
  IState get state => _state;

  @override
  List<Object?> get props => [
        fileSize,
        fileType,
        id,
        fileName,
        authorId,
        filePath,
      ];
}
