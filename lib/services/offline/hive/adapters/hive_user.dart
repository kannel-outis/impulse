import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

// ignore: must_be_immutable
class HiveUser extends HiveObject with EquatableMixin {
  final String id;
  String? previousSessionId;
  String? lastSessionDateTime;

  HiveUser({
    required this.id,
    required this.lastSessionDateTime,
    this.previousSessionId,
  });

  @override
  List<Object?> get props => [
        id,
        previousSessionId,
        lastSessionDateTime,
      ];
}

class HiveUserAdapter extends TypeAdapter<HiveUser> {
  @override
  int get typeId => 2;

  @override
  HiveUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveUser(
      id: fields[0] as String,
      previousSessionId: fields[1] as String?,
      lastSessionDateTime: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveUser obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.previousSessionId)
      ..writeByte(2)
      ..write(obj.lastSessionDateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
