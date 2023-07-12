// import 'dart:io';

// import 'package:dartz/dartz.dart';
// import 'package:impulse/app/app.dart';
// import 'package:impulse/services/services.dart';

// class ShareableItem extends Item {
//   final OnProgressCallBack? progressCallBack;
//   final OnStateChange? stateChange;
//   final (String, int) destination;
//   final Host host;

//   ShareableItem({
//     required File file,
//     required String fileType,
//     required this.host,
//     required int fileSize,
//     required String id,
//     this.progressCallBack,
//     this.stateChange,
//     required this.destination,
//   }) : super(
//           id: id,
//           file: file,
//           fileSize: fileSize,
//           fileType: fileType,
//           onProgressCallback: progressCallBack,
//           onStateChange: stateChange,
//         );

//   DownloadState _state = DownloadState.pending;

//   int _received = 0;

//   // @override
//   // Future<void> share() async {
//   //   final response = await host.shareFile(
//   //     file: file!,
//   //     destination: (destination.$1, destination.$2),
//   //     onProgress: (received, total) {
//   //       _state = TransferState.inProgress;
//   //       _received = received;
//   //       onProgressCallback?.call(received, total, _state);
//   //     },
//   //   );
//   //   final result = response.map((r) => _ResponseState.fromMap(r));
//   //   if (result is Right) {
//   //     final responseState = ((share as Right).value) as _ResponseState;
//   //     _state = responseState.state;
//   //     onStateChange?.call(_received, fileSize, file, null, _state);
//   //   } else {
//   //     final exception = (result as Left).value as AppException;
//   //     _state = TransferState.failed;
//   //     onStateChange?.call(_received, fileSize, file, exception.message, _state);
//   //   }
//   // }

//   @override
//   DownloadState get state => _state;
// }

// class _ResponseState {
//   final String stateString;

//   const _ResponseState._(this.stateString);

//   factory _ResponseState.fromMap(Map<String, dynamic> map) {
//     final state = map["state"];
//     return _ResponseState._(state);
//   }

//   DownloadState get state => DownloadState.values
//       .where((element) => element.label == stateString)
//       .first;
// }
