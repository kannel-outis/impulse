import 'package:impulse_utils/impulse_utils.dart';

class ImpulseFileSize extends FileSize {
  ImpulseFileSize(super.size);

  @override
  String get sizeToString {
    return "${super.sizeToString.trim().replaceAll(RegExp(r'\s+'), '').replaceFirst("B", "b")}/s";
  }
}
