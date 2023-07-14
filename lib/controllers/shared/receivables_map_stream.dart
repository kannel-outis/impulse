import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/services/services.dart';
import 'package:impulse/services/shared/transfer/receiveable_item.dart';

// final _receivablesMapStream = StreamProvider<Map<String, dynamic>>((ref) {
//   final controller =
//       ref.watch(serverControllerProvider).receivablesStreamController;

//   ///TODO: Remember to dispose Stream when disconnected
//   // ref.onDispose(controller.close);
//   return controller.stream;
// });

final receivableListItems =
    StateNotifierProvider<ReceiveableItemsProvider, List<Item>>((ref) {
  final stream =
      ref.watch(serverControllerProvider).receivablesStreamController.stream;

  return ReceiveableItemsProvider(stream);
});

class ReceiveableItemsProvider extends StateNotifier<List<Item>> {
  final Stream<Map<String, dynamic>> itemsStream;
  ReceiveableItemsProvider(this.itemsStream) : super([]) {
    _listen();
  }

  void _listen() {
    itemsStream.listen((event) {
      final item = ReceiveableItem.fromShareableMap(event);
      state = [...state, item];
    });
  }
}
