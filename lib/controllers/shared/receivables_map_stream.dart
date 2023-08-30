import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/services/services.dart';

// final _receivablesMapStream = StreamProvider<Map<String, dynamic>>((ref) {
//   final controller =
//       ref.watch(serverControllerProvider).receivablesStreamController;

//   ///TODO: Remember to dispose Stream when disconnected
//   // ref.onDispose(controller.close);
//   return controller.stream;
// });

final receivableListItems =
    StateNotifierProvider<ReceiveableItemsProvider, List<ReceiveableItem>>(
        (ref) {
  final stream =
      ref.read(serverControllerProvider).receivablesStreamController.stream;
  final downloadManager = ref.read(downloadManagerProvider.notifier);

  return ReceiveableItemsProvider(
      stream, downloadManager, HiveManagerImpl(), ClientImpl());
});

class ReceiveableItemsProvider extends StateNotifier<List<ReceiveableItem>> {
  final Stream<Map<String, dynamic>> itemsStream;
  final DownloadManager downloadManager;
  final HiveManager hiveManager;
  final Client client;
  ReceiveableItemsProvider(
    this.itemsStream,
    this.downloadManager,
    this.hiveManager,
    this.client,
  ) : super([]) {
    _listen();
  }

  void _listen() {
    itemsStream.listen((event) async {
      final item = ReceiveableItem.fromShareableMap(event);

      ///save each receivable to hive offline db
      await hiveManager.saveItem(item);

      ///get the saved instance of that receiveable using the id
      ///(which we used to save it to make each item uniques and also for easy access)
      final hiveItem = hiveManager.getReceiveableItemWithKey(item.id);

      ///define the onprogress call back so that we can collect the state and proccessed byte
      ///and save to thet hive instance.
      // item.onProgressCallback = (received, totalSize, state) async {
      //   hiveItem?.iState = state;
      //   hiveItem?.processedBytes = received;

      //   await hiveItem?.save();
      // };

      void listener(int received, int totalSize, file, String? reason, state) {
        hiveItem?.iState = state;
        hiveItem?.processedBytes = received;
        hiveItem?.setEndTime = DateTime.now();
        hiveItem?.save();
        if (state.isCompleted) {
          item.removeListener(listener);
        }
      }

      item.addListener(listener);
      state = [...state, item];

      downloadManager.addToQueue([item]);
      if (downloadManager.isDownloading == false) {
        downloadManager.download();
      }
    });
  }

  void clear() {
    state = [];
  }

  void cancelItemWithId(ReceiveableItem item) async {
    await downloadManager.removeItemFromDownloadList(item);
    await client.cancelItem(item.homeDestination!, item.id);
    state.removeWhere((element) => element.id == item.id);
    state = [...state];
  }
}
