part of 'shareable_item.dart';

class _ShareableFile extends ShareableItem {
  final File file;
  _ShareableFile({
    required this.file,
    required String fileType,
    required int fileSize,
    required String id,
    (String, int)? homeDestination,
    String? altName,
    required String authorId,
  }) : super(
          id: id,
          file: file,
          fileSize: fileSize,
          fileType: fileType,
          authorId: authorId,
          homeDestination: homeDestination,
          altName: altName,
        );

  @override
  Future<void> upload(Future Function(Stream<List<int>> data) future,
      {int start = 0, Function(int)? onDone}) async {
    int bytesDownloadedByClient = start;
    var fileStream = file.openRead(start);
    await future(fileStream.map((event) {
      bytesDownloadedByClient += event.length;

      ///Calling notyfyListeners() and notifying every listener
      updateProgress(
        bytesDownloadedByClient,
        fileSize,
        IState.inProgress,
      );
      return event;
    }));

    updateProgress(
      bytesDownloadedByClient,
      fileSize,
      bytesDownloadedByClient != fileSize ? IState.paused : IState.completed,
    );
    onDone?.call(bytesDownloadedByClient);
  }
}
