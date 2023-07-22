import 'dart:io';

import 'package:hive/hive.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';

// ignore: must_be_immutable
class HiveItem extends Item with HiveObjectMixin {
  final String fileId;
  final String path;
  final String type;
  final int totalSize;
  final String? filename;
  final String homeUserId;
  final String homeDestinationAddress;
  final int homeDestinationPort;
  int processedBytes;
  IState iState;
  // String progress;

  HiveItem({
    required this.fileId,
    required this.path,
    required this.filename,
    required this.type,
    required this.totalSize,
    required this.homeUserId,
    required this.homeDestinationAddress,
    required this.homeDestinationPort,
    this.processedBytes = 0,
    // this.progress ="0",
    this.iState = IState.pending,
  }) : super(
          authorId: homeUserId,
          file: File(path),
          fileSize: totalSize,
          fileType: type,
          homeDestination: (homeDestinationAddress, homeDestinationPort),
          id: fileId,
          fileName: filename,
        );

  @override
  List<Object?> get props => [
        fileSize,
        fileType,
        id,
        fileName,
        authorId,
        filePath,
      ];

  @override
  Map<String, dynamic> toMap() {
    return {};
  }
}

class HiveItemAdapter extends TypeAdapter<HiveItem> {
  @override
  int get typeId => 1;

  @override
  HiveItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveItem(
      fileId: fields[0] as String,
      filename: fields[1] as String,
      path: fields[2] as String,
      homeUserId: fields[3] as String,
      type: fields[4] as String,
      homeDestinationAddress: fields[5] as String,
      homeDestinationPort: fields[6] as int,
      totalSize: fields[7] as int,
      processedBytes: fields[8] as int,
      iState: fields[9] as IState,
    );
  }

  @override
  void write(BinaryWriter writer, HiveItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.fileId)
      ..writeByte(1)
      ..write(obj.filename)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.homeUserId)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.homeDestinationAddress)
      ..writeByte(6)
      ..write(obj.homeDestinationPort)
      ..writeByte(7)
      ..write(obj.totalSize)
      ..writeByte(8)
      ..write(obj.processedBytes)
      ..writeByte(9)
      ..write(obj.iState);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
