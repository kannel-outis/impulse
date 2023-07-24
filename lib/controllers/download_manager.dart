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
        Future.delayed(const Duration(seconds: 2), () {
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
    item.addListener((received, totalSize, file, reason, state) {
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
    });
    ///////
    log("${item.id} from download");
    await item.receive().then((value) async {
      if (item.state == IState.completed) {
        _listOfWaitingReceivables
            .removeWhere((element) => element.state == IState.completed);
      }
      // currentItemAtIndex += 1;
      await download();
    });
  }

  // void debounce(){
  //  DateTime now = DateTime.now();

  // if (_debounceTimer == null || !_debounceTimer!.isActive) {
  //   _debounceTimer?.cancel();
  //   _debounceTimer = Timer(const Duration(seconds: 1), () {
  //     final duration = now.difference(_previouseReceivedTime).inSeconds;
  //     final bytesPerInterval = (received - _previouseReceivedByte) / duration;
  //     _mbps = bytesPerInterval.isNegative ? 0 : bytesPerInterval.toInt();

  //     log(bytesPerInterval.toString());
  //     _previouseReceivedTime = now;
  //     _previouseReceivedByte = received;
  //   });
  // }
  // }

  void pause(ReceiveableItem item) {
    final index = _listOfWaitingReceivables
        .indexWhere((element) => element.id == item.id);
    _listOfPaused.add(_listOfWaitingReceivables[index]);
    _listOfWaitingReceivables.removeAt(index);
  }
}
