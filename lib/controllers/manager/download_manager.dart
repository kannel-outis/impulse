import 'dart:async';
import 'dart:developer';

import 'mbps.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';

final downloadManagerProvider =
    StateNotifierProvider<DownloadManager, (int, Item?)>((ref) {
  // final receivables = ref.read(receivableListItems);
  return DownloadManager();
});

class DownloadManager extends MBps {
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

  // Timer? _debounceTimer;

  Future<void> removeItemFromDownloadList(Item item) async {
    if (item.state.isInProgress) {
      await item.cancel();
    }
    _listOfWaitingReceivables.removeWhere((element) => element.id == item.id);
  }

  Future<void> download({int index = 0}) async {
    // return;
    if (_listOfWaitingReceivables.isEmpty ||
        index > _listOfWaitingReceivables.length - 1) {
      _downloading = false;
      if (_downloading == false) {
        Future.delayed(const Duration(seconds: 1), () {
          state = (0, state.$2);
          cancelMbps();
        });
      }
      return;
    }
    numberOfDownloadedItems = index;
    _downloading = true;
    final item = _listOfWaitingReceivables.first;
    state = (previousMBps, item);
    /////
    item.addListener(_listener);
    ///////
    try {
      await item.receive().then((value) async {
        if (item.state.isCompleted ||
            item.state.isCanceled ||
            item.state.isFailed) {
          _listOfWaitingReceivables
              .removeWhere((element) => element.id == item.id);
        }
        item.removeListener(_listener);
        // currentItemAtIndex += 1;
        await download();
      });
    } catch (e) {
      _listOfWaitingReceivables.removeWhere((element) => element.id == item.id);
      item.removeListener(_listener);
      await download();
    }
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

    mbps(now, received, totalSize, file, reason, state);
  }
}
