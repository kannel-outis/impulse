import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/services/services.dart';
import 'package:riverpod/riverpod.dart';

final shareableItemsProvider =
    StateNotifierProvider<ShareableItemsProvider, List<ShareableItem>>((ref) {
  return ShareableItemsProvider(ref);
});

class ShareableItemsProvider extends StateNotifier<List<ShareableItem>> {
  final Ref ref;
  ShareableItemsProvider(this.ref) : super([]);
  List<Item> _filtered = [];

  void addAllItems(List<ShareableItem> items) {
    state = [...state, ..._filteredList(items)];
    ref.read(connectedUserPreviousSessionStateProvider)!.$2
      ..previousSessionShareable = state.map((e) => e.id).toList()
      ..save();
  }

  void cancelItemWithId(String itemId) {
    state.removeWhere((element) => element.id == itemId);
    state = [...state];
  }

  void clear() {
    state = [];
  }

  List<Item> get filteredList => _filtered;

  ///filter list so that they are not sent more than once
  List<ShareableItem> _filteredList(List<ShareableItem> items) {
    return _filtered = items
        .where((element) =>
            !state.map((e) => e.id).toList().contains(element.id) &&
            !state.map((e) => e.filePath).toList().contains(element.filePath))
        .toList();
  }
}
