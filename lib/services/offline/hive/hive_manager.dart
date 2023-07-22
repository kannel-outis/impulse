import 'package:impulse/services/services.dart';

abstract class HiveManager {
  Future<void> saveItem(Item item);
  List<Item> getAllShareableItems();
  List<Item> getAllReceiveableItems();
}
