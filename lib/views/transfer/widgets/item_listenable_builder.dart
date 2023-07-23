// ignore_for_file: library_private_types_in_public_api, unused_element, file_names

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';

typedef _ItemListenableBuilder = Widget Function(
  BuildContext context,
  double percentage,
  int mbps,
  IState state,
);

class ItemListenableBuilder extends StatefulWidget {
  final StateListenable listenable;
  final _ItemListenableBuilder builder;
  final Widget? child;
  const ItemListenableBuilder({
    super.key,
    this.child,
    required this.builder,
    required this.listenable,
  });

  @override
  State<ItemListenableBuilder> createState() => _ItemListenableBuilderState();
}

class _ItemListenableBuilderState extends State<ItemListenableBuilder> {
  double _progress = 0;
  IState _state = IState.pending;
  int _mbps = 0;
  DateTime _previouseReceived = DateTime.now();
  int _previouseReceivedByte = 0;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // _timer = Timer(const Duration(seconds: 1), () {
    //   setState(() {});
    // });

    updateStateAndProgress();
  }

  void updateStateAndProgress(
      {bool refreshListener = false, ItemListenableBuilder? oldWidget}) {
    _state = _listenableAsItem(widget).state;
    _progress = _listenableAsItem(widget).proccessedBytes /
        _listenableAsItem(widget).fileSize;

    if (refreshListener && oldWidget != null) {
      _listenableAsItem(oldWidget).removeListener(_listener);
    }
    _listenableAsItem(widget).addListener(_listener);
  }

  void _listener(
    int received,
    int totalSize,
    file,
    String? reason,
    IState state,
  ) {
    _progress = received / totalSize;
    _state = state;

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ItemListenableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateStateAndProgress(refreshListener: true, oldWidget: oldWidget);
  }

  @override
  void dispose() {
    _listenableAsItem(widget).removeListener(_listener);
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? widget.builder(context, _progress, _mbps, _state);
  }

  Item _listenableAsItem(ItemListenableBuilder widget) {
    return widget.listenable as Item;
  }
}
