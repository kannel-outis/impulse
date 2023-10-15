import 'dart:io';

import 'package:impulse/app/app.dart';

typedef OnProgressCallBack = Function(
  int received,
  int totalSize,
  IState state,
);

typedef OnStateChange = Function(
  int received,
  int totalSize,
  FileSystemEntity? file,
  String? reason,
  IState state,
);
