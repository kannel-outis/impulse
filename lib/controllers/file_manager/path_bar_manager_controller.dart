import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/models/models.dart';

final pathController = StateNotifierProvider<PathController, List<Path>>((ref) {
  return PathController();
});

class PathController extends StateNotifier<List<Path>> {
  PathController()
      : super([Path(location: ImpulseRouter.routes.folder, altName: "Root")]);

  void addPathToNav(Path path) {
    if (state.map((e) => e.location).toList().contains(path.location)) {
      return;
    }
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
