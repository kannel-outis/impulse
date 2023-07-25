import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';

final downloadManagerProvider =
    StateNotifierProvider<DownloadManager, (int, Item?)>((ref) {
  // final receivables = ref.read(receivableListItems);
  return DownloadManager();
});

class DownloadManager extends StateNotifier<(int mBps, Item? currentItem)> {
  final List<ReceiveableItem> items;
  DownloadManager({this.items = const []}) : super((0, null));

  // ignore: prefer_final_fields
  final List<ReceiveableItem> _listOfWaitingReceivables = <ReceiveableItem>[];
  final _listOfPaused = <ReceiveableItem>[];

  int numberOfDownloadedItems = 0;
  bool _downloading = false;
  bool get isDownloading => _downloading;

  void addToQueue(Iterable<ReceiveableItem> newReceivabels) {
    // _listOfWaitingReceivables = [
    //   ..._listOfWaitingReceivables,
    //   ...newReceivabels
    // ];
    for (var item in newReceivabels) {
      if (_listOfWaitingReceivables
              .map((e) => e.id)
              .toList()
              .contains(item.id) ==
          false) {
        _listOfWaitingReceivables.add(item);
      }
    }
  }

  DateTime _previouseReceivedTime = DateTime.now();
  int _previouseReceivedByte = 0;
  int _previousMBps = 0;

  Timer? _debounceTimer;

  Future<void> download({int index = 0}) async {
    // return;
    if (_listOfWaitingReceivables.isEmpty ||
        index > _listOfWaitingReceivables.length - 1) {
      _downloading = false;
      if (_downloading == false) {
        Future.delayed(const Duration(seconds: 1), () {
          state = (0, state.$2);
          _debounceTimer?.cancel();
        });
      }
      return;
    }
    numberOfDownloadedItems = index;
    _downloading = true;
    final item = _listOfWaitingReceivables.first;
    state = (0, item);
    /////
    item.addListener(_listener);
    ///////
    log("${item.id} from download");
    await item.receive().then((value) async {
      if (item.state.isCompleted) {
        _listOfWaitingReceivables
            .removeWhere((element) => element.state == IState.completed);
      }
      item.removeListener(_listener);
      // currentItemAtIndex += 1;
      await download();
    });
  }

  void pauseCurrentDownload() {
    state.$2?.pause();

    if (state.$2 == null) return;
    final index = _listOfWaitingReceivables
        .indexWhere((element) => element.id == state.$2!.id);
    _listOfPaused.add(_listOfWaitingReceivables[index]);
    _listOfWaitingReceivables.removeAt(index);
  }

  void resumeDownload(ReceiveableItem item) {
    ///Check if item was paused
    final contains = _listOfPaused.map((e) => e.id).contains(item.id);
    if (contains) {
      ///check if receivable list is empty, if so, add and call download();
      if (_listOfWaitingReceivables.isEmpty) {
        item.start = item.downloadedBytes;
        _listOfWaitingReceivables.add(item);
        download();
      } else {
        ///if not empty, that means something is currently downloading, add to next on the list

        item.start = item.downloadedBytes;

        _listOfWaitingReceivables.insert(1, item);
        item.changeState(IState.waiting);

        ///remove from paused list
        _listOfPaused.removeWhere((element) => element.id == item.id);
      }
    }
  }

  void _listener(received, totalSize, file, reason, state) {
    DateTime now = DateTime.now();

    if (_debounceTimer == null || !_debounceTimer!.isActive) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(seconds: 1), () {
        final duration = now.difference(_previouseReceivedTime).inSeconds;
        final bytesPerInterval =
            (received - _previouseReceivedByte) ~/ duration;
        final mBps = bytesPerInterval.isNegative
            ? _previousMBps
            : bytesPerInterval.toInt();
        this.state = (mBps, this.state.$2);
        _previousMBps = mBps;

        log(bytesPerInterval.toString());
        _previouseReceivedTime = now;
        _previouseReceivedByte = received;
      });
    }
  }
}
