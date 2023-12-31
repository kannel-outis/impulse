import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

// ignore: must_be_immutable
class HiveSession extends HiveObject with EquatableMixin {
  final String userId;
  String? previousSessionId;
  String? lastSessionDateTime;
  List<String> previousSessionReceivable;
  List<String> previousSessionShareable;

  HiveSession({
    required this.userId,
    this.lastSessionDateTime,
    required this.previousSessionId,
    this.previousSessionReceivable = const [],
    this.previousSessionShareable = const [],
  });

  @override
  List<Object?> get props => [
        userId,
        previousSessionId,
        lastSessionDateTime,
      ];

  HiveSession newInstance() {
    return HiveSession(
      userId: userId,
      lastSessionDateTime: lastSessionDateTime,
      previousSessionId: previousSessionId,
      previousSessionReceivable: previousSessionReceivable,
      previousSessionShareable: previousSessionShareable,
    );
  }
}

class HiveUserAdapter extends TypeAdapter<HiveSession> {
  @override
  int get typeId => 2;

  @override
  HiveSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSession(
      userId: fields[0] as String,
      previousSessionId: fields[1] as String?,
      lastSessionDateTime: fields[2] as String?,
      previousSessionReceivable: List<String>.from(fields[3] as List),
      previousSessionShareable: List<String>.from(fields[4] as List),
    );
  }

  @override
  void write(BinaryWriter writer, HiveSession obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.previousSessionId)
      ..writeByte(2)
      ..write(obj.lastSessionDateTime)
      ..writeByte(3)
      ..write(obj.previousSessionReceivable)
      ..writeByte(4)
      ..write(obj.previousSessionShareable);
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
