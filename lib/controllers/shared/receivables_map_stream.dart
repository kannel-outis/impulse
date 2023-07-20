import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/controllers/download_manager.dart';
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
      ref.watch(serverControllerProvider).receivablesStreamController.stream;
  final downloadManager = ref.read(downloadManagerProvider);

  return ReceiveableItemsProvider(stream, downloadManager);
});

class ReceiveableItemsProvider extends StateNotifier<List<ReceiveableItem>> {
  final Stream<Map<String, dynamic>> itemsStream;
  final DownloadManager downloadManager;
  ReceiveableItemsProvider(this.itemsStream, this.downloadManager) : super([]) {
    _listen();
  }

  void _listen() {
    itemsStream.listen((event) {
      final item = ReceiveableItem.fromShareableMap(event);
      state = [...state, item];

      downloadManager.addToQueue([item]);
      if (downloadManager.isDownloading == false) {
        downloadManager.download();
      }
    });
  }
}
