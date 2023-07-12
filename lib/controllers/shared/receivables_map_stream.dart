import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/controllers/controllers.dart';

final receivablesMapStream = StreamProvider<Map<String, dynamic>>((ref) {
  final controller =
      ref.watch(serverControllerProvider).receivablesStreamController;

  ///TODO: Remember to dispose Stream when disconnected
  ref.onDispose(controller.close);
  return controller.stream;
});
