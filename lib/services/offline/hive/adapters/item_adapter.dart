import 'package:hive/hive.dart';
import 'package:impulse/services/services.dart';

class ItemAdapter extends TypeAdapter<Item> {
  @override
  int get typeId => 0;

  @override
  Item read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    throw UnimplementedError();
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    // writer..write(value)
  }
}
