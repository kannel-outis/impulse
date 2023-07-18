import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/services/services.dart';

final downloadManagerProvider = Provider<DownloadManager>((ref) {
  // final receivables = ref.read(receivableListItems);
  return DownloadManager();
});

class DownloadManager {
  final List<ReceiveableItem> items;
  DownloadManager({this.items = const []});

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
    for (var l in _listOfWaitingReceivables) {
      print(l.id);
    }
  }

  Future<void> download({int index = 0}) async {
    // return;
    if (_listOfWaitingReceivables.isEmpty ||
        index > _listOfWaitingReceivables.length - 1) {
      _downloading = false;
      print("empty");
      return;
    }
    numberOfDownloadedItems = index;
    _downloading = true;
    final item = _listOfWaitingReceivables.first;
    // print(
    //     "${item.id} file coming from ${item.filePath} with size ${item.fileSize}");
    // download(index: numberOfDownloadedItems + 1);
    log("${item.id} from download");
    await item.receive().then((value) async {
      if (item.state == DownloadState.completed) {
        _listOfWaitingReceivables
            .removeWhere((element) => element.state == DownloadState.completed);
      }
      print(_listOfWaitingReceivables.length);
      // currentItemAtIndex += 1;
      await download(index: numberOfDownloadedItems + 1);
    });
  }

  void pause(ReceiveableItem item) {
    final index = _listOfWaitingReceivables
        .indexWhere((element) => element.id == item.id);
    _listOfPaused.add(_listOfWaitingReceivables[index]);
    _listOfWaitingReceivables.removeAt(index);
  }
}
