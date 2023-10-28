part of 'receiveable_item.dart';

class _ReceiveableFolder extends ReceiveableItem
    with MultipleItemsStart<ReceiverItem> {
  final List<ReceiverItem> items;
  final _MetaData metaData;
  final String groupId;
  final int itemCount;
  _ReceiveableFolder({
    int start = 0,
    required this.metaData,
    required this.items,
    required this.groupId,
    required this.itemCount,
  }) : super(
          authorId: metaData.senderId,
          id: metaData.id,
          file: Directory(metaData.filePath),
          fileSize: metaData.fileSize,
          fileType: metaData.fileType,
          homeDestination: metaData.homeDestination,
          altName: metaData.altName,
        );

  // @override
  // int get fileSize {
  //   int size = 0;
  //   for (var item in items) {
  //     size += item.fileSize;
  //   }
  //   return size;
  // }

  @override
  List<ReceiverItem> get files => items;

  bool _downloadCanceled = false;
  bool _downloadCompleted = false;
  bool _downloadFailed = false;
  bool _downloading = false;
  bool _downloadPaused = false;
  int _downloadedBytes = 0;

  Future<void> _close([bool complete = false]) async {
    final totalBytes = _downloadedBytes;

    if (complete) {
      _downloadCompleted = complete;
      notifyListeners(_downloadedBytes, fileSize,
          _currentItem?.fileSystemEntity as File, "", state);
    } else if (_downloadPaused) {
      _downloadCanceled = false;
      _downloadFailed = false;
      _downloadCompleted = false;
      await _currentItem?.pause();
    } else if (_downloadCanceled) {
      _downloadPaused = false;
      _downloadFailed = false;
      _downloadCompleted = false;
      await _currentItem?.cancel();
    } else {
      _downloadFailed = true;
    }

    _downloading = false;

    notifyListeners(totalBytes, fileSize, fileSystemEntity, "", state);

    startTime = null;
  }

  ReceiverItem? _currentItem;
  int _currentIndex = -1;
  int get currentIndex => _currentIndex;
  int _startIndex = 0;

  ({int index, int fileProccessed}) get _start => startPosition(start);

  @override
  Future<void> receive() async {
    _downloading = true;
    _startIndex = _start.index;
    for (var i = _startIndex; i < items.length; i++) {
      if (!_downloading) {
        _();
        break;
      }
      _currentItem = items[i]..start = _start.fileProccessed;
      _currentIndex = i;
      _currentItem?.addListener(_listerner);
      await _currentItem?.receive();
    }
    _();
    await _close(true);
    return;
  }

  void _() {
    _currentItem = null;
    _currentIndex = -1;
    _downloadCompleted = true;
  }

  @override
  Future<void> cancel() async {
    _downloadCanceled = true;
    _currentItem?.cancel();
    //Delete folder
  }

  @override
  void changeState(IState newState) {}

  @override
  Future<void> pause() async {
    _downloadPaused = true;
    await _close();
  }

  @override
  int get proccessedBytes => _downloadedBytes;

  @override
  List<Object?> get props => throw UnimplementedError();

  @override
  String? get mime => "folder";

  @override
  IState get state {
    if (_downloadCanceled) return IState.canceled;
    if (_downloadCompleted) return IState.completed;
    if (_downloadFailed) return IState.failed;
    if (_downloading) return IState.inProgress;
    if (_downloadPaused) return IState.paused;
    return IState.pending;
  }

  void _listerner(
      int received, int _, FileSystemEntity? file, String? reason, state) {
    _downloadedBytes += received;
    notifyListeners(
        _downloadedBytes, fileSize, fileSystemEntity, reason, this.state);
  }
}
