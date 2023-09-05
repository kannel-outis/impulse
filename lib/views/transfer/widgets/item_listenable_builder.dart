// ignore_for_file: library_private_types_in_public_api, unused_element, file_names

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';

typedef _ItemListenableBuilder = Widget Function(
  BuildContext context,
  double percentage,
  IState state,
  Widget? child,
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
  IState _prevState = IState.pending;

  @override
  void initState() {
    super.initState();
    // _timer = Timer(const Duration(seconds: 1), () {
    //   setState(() {});
    // });

    updateStateAndProgress();
  }

  final Debouncer _debouncer = Debouncer(duration: const Duration(seconds: 1));

  void updateStateAndProgress(
      {bool refreshListener = false, ItemListenableBuilder? oldWidget}) {
    _state = _listenableAsItem(widget).state;
    _prevState = _state;
    _progress = _listenableAsItem(widget).proccessedBytes /
        _listenableAsItem(widget).fileSize;
    log("${(widget.listenable as Item).id}: ${(widget.listenable as Item).proccessedBytes}");

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
    if (_prevState != _state && mounted) setState(() {});

    _debouncer.debounce(() {
      if (_prevState != _state) {
        return;
      }
      if (mounted) setState(() {});
    });

    // setState(() {});

    _prevState = state;

    // if (state != IState.inProgress) {
    //   _debounceTimer?.cancel();
    //   _debounceTimer = null;
    // }
  }

  @override
  void didUpdateWidget(covariant ItemListenableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateStateAndProgress(refreshListener: true, oldWidget: oldWidget);
  }

  @override
  void dispose() {
    _listenableAsItem(widget).removeListener(_listener);
    _debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _progress, _state, widget.child);
  }

  Item _listenableAsItem(ItemListenableBuilder widget) {
    return widget.listenable as Item;
  }
}
