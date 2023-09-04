import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse/services/services.dart';

// final _receivablesMapStream = StreamProvider<Map<String, dynamic>>((ref) {
//   final controller =
//       ref.watch(serverControllerProvider).receivablesStreamController;

//   // ref.onDispose(controller.close);
//   return controller.stream;
// });

final receivableListItems =
    StateNotifierProvider<ReceiveableItemsProvider, List<ReceiveableItem>>(
        (ref) {
  // final stream =
  //     ref.read(serverControllerProvider).receivablesStreamController.stream;
  final downloadManager = ref.read(downloadManagerProvider.notifier);

  return ReceiveableItemsProvider(
    ref,
    downloadManager,
    HiveManagerImpl(),
    ClientImpl(),
  );
});

class ReceiveableItemsProvider extends StateNotifier<List<ReceiveableItem>> {
  final Ref ref;
  final DownloadManager downloadManager;
  final HiveManager hiveManager;
  final Client client;
  ReceiveableItemsProvider(
    this.ref,
    this.downloadManager,
    this.hiveManager,
    this.client,
  ) : super([]) {
    _listen();
  }

  void _listen() {
    ref
        .read(serverControllerProvider)
        .receivablesStreamController
        .stream
        .listen((event) async {
      final item = ReceiveableItem.fromShareableMap(event);

      // if (ref
      //     .read(connectedUserPreviousSessionStateProvider.notifier)
      //     .hasSetNewPrevSession) {
      _nextSession.previousSessionReceivable = [
        ..._nextSession.previousSessionReceivable,
        item.id
      ];
      _nextSession.save();
      // }

      ///save each receivable to hive offline db
      await hiveManager.saveItem(item, session!.id);

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

          ///if this item is completed, remove from the nextSession receivable and save to db
          _nextSession.previousSessionReceivable
              .removeWhere((element) => element == item.id);
          _nextSession.save();
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

  Session? get session => ref.read(currentSessionStateProvider);
  // HiveSession get _prevSessions =>
  //     ref.read(connectedUserPreviousSessionStateProvider)!.$1;
  HiveSession get _nextSession =>
      ref.read(connectedUserPreviousSessionStateProvider)!.$2;

  @override
  void dispose() {
    super.dispose();
    ref.read(serverControllerProvider).receivablesStreamController.close();
  }

  void clear() {
    state = [];
  }

  void continueDownloads(HiveItem hiveItem) {
    final item = ReceiveableItem(
      file: File(hiveItem.path),
      fileType: hiveItem.fileType,
      fileSize: hiveItem.fileSize,
      id: hiveItem.id,
      homeDestination: (
        ref.read(connectUserStateProvider)!.ipAddress!,
        ref.read(connectUserStateProvider)!.port!
      ),
      authorId: hiveItem.authorId,
      start: hiveItem.processedBytes,
    );

    void listener(int received, int totalSize, file, String? reason, state) {
      hiveItem.iState = state;
      hiveItem.processedBytes = received;
      hiveItem.setEndTime = DateTime.now();
      hiveItem.save();

      // update prevItem
      // prevItem.iState = state;
      // prevItem.processedBytes = received;
      // prevItem.setEndTime = DateTime.now();
      // prevItem.save();
      if (state.isCompleted) {
        item.removeListener(listener);

        ///if this item is completed, remove from the prevsession receivable and save to db
        _nextSession.previousSessionReceivable
            .removeWhere((element) => element == item.id);
        _nextSession.save();
      }
    }

    item.addListener(listener);
    state = [...state, item];

    downloadManager.addToQueue([item]);
    if (downloadManager.isDownloading == false) {
      downloadManager.download();
    }
  }

  void cancelItemWithId(ReceiveableItem item) async {
    await downloadManager.removeItemFromDownloadList(item);
    state.removeWhere((element) => element.id == item.id);
    state = [...state];
    hiveManager.removeItemWithKey(item.id);
    await client.cancelItem(item.homeDestination!, item.id);
  }
}
