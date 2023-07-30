import 'package:hive/hive.dart';
import 'package:impulse/app/app.dart';

class IStateAdapter extends TypeAdapter<IState> {
  @override
  final int typeId = 6;

  @override
  IState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IState.canceled;
      case 1:
        return IState.completed;
      case 2:
        return IState.paused;
      case 3:
        return IState.pending;
      case 4:
        return IState.failed;
      case 5:
        return IState.waiting;
      default:
        return IState.inProgress;
    }
  }

  @override
  void write(BinaryWriter writer, IState obj) {
    switch (obj) {
      case IState.canceled:
        writer.writeByte(0);
        break;
      case IState.completed:
        writer.writeByte(1);
        break;
      case IState.paused:
        writer.writeByte(2);
        break;
      case IState.pending:
        writer.writeByte(3);
        break;
      case IState.failed:
        writer.writeByte(4);
        break;
      case IState.waiting:
        writer.writeByte(5);
        break;
      case IState.inProgress:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
