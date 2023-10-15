// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';
import 'package:riverpod/riverpod.dart';

class MBps extends StateNotifier<
    ({int mBps, Item? currentDownload, Duration remainingTime})> {
  MBps(super.state);

  DateTime _previouseReceivedTime = DateTime.now();
  int _previouseReceivedByte = 0;
  int previousMBps = 0;

  final Debouncer _debouncer = Debouncer(duration: const Duration(seconds: 1));

  void mbps(now, received, totalSize, file, reason, state) {
    _debouncer.debounce(
      () => debouncedFunction(now, received, totalSize, file, reason, state),
    );
  }

  int _totalDownloadSize = 0;
  int _totalReceived = 0;

  @protected
  set totalDownloadSize(int size) {
    _totalDownloadSize = size;
  }

  @protected
  set totalReceived(int size) {
    _totalReceived = size;
  }

  @protected
  int get totalDownloadSize => _totalDownloadSize;

  @protected
  int get totalReceived => _totalReceived;

  void cancelMbps() {
    _debouncer.cancel();
  }

  void debouncedFunction(
    DateTime now,
    int received,
    int totalSize,
    file,
    String reason,
    IState state,
  ) {
    final duration = now.difference(_previouseReceivedTime).inSeconds;
    final bytesPerInterval = (received - _previouseReceivedByte) ~/ duration;
    final mBps =
        bytesPerInterval.isNegative ? previousMBps : bytesPerInterval.toInt();
    _totalReceived += mBps;
    final remainingBytes = _totalDownloadSize - _totalReceived;
    final remainingTime = (remainingBytes ~/ mBps);
    this.state = (
      mBps: mBps,
      currentDownload: this.state.currentDownload,
      remainingTime: Duration(
        seconds: remainingTime.round(),
      )
    );
    previousMBps = mBps;

    _previouseReceivedTime = now;
    _previouseReceivedByte = received;
  }
}
