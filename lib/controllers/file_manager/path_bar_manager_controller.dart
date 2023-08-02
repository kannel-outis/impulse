import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/models/models.dart';

final pathController = StateNotifierProvider<PathController, List<Path>>((ref) {
  return PathController();
});

class PathController extends StateNotifier<List<Path>> {
  PathController() : super([]);

  void addPathToNav(Path path) {
    state = [...state, path];
  }

  void pop() {
    state.removeLast();
    state = [...state];
  }

  void removeUntil(Path path) {
    var p = state.last;

    //*if the last path is not the passed path, remove until we get to the passed path
    while (p.path != path.path) {
      state.removeLast();
      p = state.last;
    }
    state = [...state];
  }
}
