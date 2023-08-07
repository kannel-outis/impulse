import 'dart:io';

import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';

// ignore: must_be_immutable
class ShareableItem extends Item {
  // final OnProgressCallBack? progressCallBack;
  // final OnStateChange? stateChange;
  final Host? host;
  final String? altName;

  ShareableItem({
    required File file,
    required String fileType,
    this.host,
    required int fileSize,
    required String id,
    // this.progressCallBack,
    // this.stateChange
    (String, int)? homeDestination,
    this.altName,
    required String authorId,
  }) : super(
          id: id,
          file: file,
          fileSize: fileSize,
          fileType: fileType,
          // onProgressCallback: progressCallBack,
          // onStateChange: stateChange,
          authorId: authorId,
          homeDestination: homeDestination,
          fileName: altName ?? file.path.split(Platform.pathSeparator).last,
        );

  IState _state = IState.pending;

  int sentBytes = 0;

  ///should be called from the server
  void updateProgress(int received, int totalSize, IState state) {
    _state = state;
    sentBytes = received;
    // onProgressCallback?.call(received, totalSize, state);
    notifyListeners(received, totalSize, file, "", state);
  }

  @override
  int get proccessedBytes => sentBytes;

  // @override
  // Future<void> share() async {
  //   final response = await host.shareFile(
  //     file: file!,
  //     destination: (destination.$1, destination.$2),
  //     onProgress: (received, total) {
  //       _state = TransferState.inProgress;
  //       _received = received;
  //       onProgressCallback?.call(received, total, _state);
  //     },
  //   );
  //   final result = response.map((r) => _ResponseState.fromMap(r));
  //   if (result is Right) {
  //     final responseState = ((share as Right).value) as _ResponseState;
  //     _state = responseState.state;
  //     onStateChange?.call(_received, fileSize, file, null, _state);
  //   } else {
  //     final exception = (result as Left).value as AppException;
  //     _state = TransferState.failed;
  //     onStateChange?.call(_received, fileSize, file, exception.message, _state);
  //   }
  // }

  @override
  IState get state => _state;

  @override
  Map<String, dynamic> toMap() {
    return {
      "fileSize": fileSize,
      "fileType": fileType,
      "fileId": id,
      "senderId": authorId,
      "fileName": fileName,
      "altName": altName,
      "homeDestination": {
        "ip": homeDestination!.$1,
        "port": homeDestination!.$2,
      }
    };
  }

  @override
  List<Object?> get props => [
        fileSize,
        fileType,
        id,
        fileName,
        authorId,
        filePath,
      ];
}

// class _ResponseState {
//   final String stateString;

//   const _ResponseState._(this.stateString);

//   factory _ResponseState.fromMap(Map<String, dynamic> map) {
//     final state = map["state"];
//     return _ResponseState._(state);
//   }

//   IState get state => IState.values
//       .where((element) => element.label == stateString)
//       .first;
// }
