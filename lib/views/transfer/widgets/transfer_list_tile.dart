import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';

class TransferListTile extends StatefulWidget {
  final double height;
  final bool mini;
  final Item item;
  const TransferListTile({
    this.height = 100,
    this.mini = false,
    required this.item,
    super.key,
  });

  @override
  State<TransferListTile> createState() => _TransferListTileState();
}

class _TransferListTileState extends State<TransferListTile> {
  double get factor {
    const defaultHeight = 100;
    return widget.height / defaultHeight;
  }

  double _progress = 0;
  DownloadState _state = DownloadState.pending;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    // _timer = Timer(const Duration(seconds: 1), () {
    //   setState(() {});
    // });

    // log((widget.item as ShareableItem).state.toString());
    // updateStateAndProgress();
    updateStateAndProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void updateStateAndProgress() {
    _state = () {
      if (widget.item is ShareableItem) {
        return (widget.item as ShareableItem).state;
      } else {
        return (widget.item as ReceiveableItem).state;
      }
    }();
    _progress = () {
      if (widget.item is ShareableItem) {
        return (widget.item as ShareableItem).sent;
      } else {
        return (widget.item as ReceiveableItem).downloadedBytes /
            widget.item.fileSize;
      }
    }();
    widget.item.onProgressCallback = (
      int received,
      int totalSize,
      DownloadState state,
    ) {
      _progress = received / totalSize;
      _state = state;
      if (mounted) {
        setState(() {});
      }
      if (widget.item is ReceiveableItem) {
        print(_progress);
      }
    };
  }

  @override
  void didUpdateWidget(covariant TransferListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.item.id != widget.item.id) {
    updateStateAndProgress();
    // }
  }

  @override
  void dispose() {
    widget.item.onProgressCallback = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: widget.height,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(
            bottom: widget.mini ? 0 : $styles.insets.lg,
          ),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            // boxShadow: $styles.shadows.boxShadowSmall,
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Container(
                height: 70 * factor,
                width: 70 * factor,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      AssetsImage.android_icon_placeholder,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item is ReceiveableItem
                          ? (widget.item as ReceiveableItem).altName ??
                              widget.item.fileName ??
                              widget.item.name
                          : widget.item.fileName ?? widget.item.name,
                      style: $styles.text.body,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.item.itemSize.sizeToString,
                          style: $styles.text.body,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            _state.label,
                            style: $styles.text.body.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: widget.height,
          width: MediaQuery.of(context).size.width > 700
              ? 700 * _progress
              : MediaQuery.of(context).size.width * _progress,
          constraints:
              widget.mini ? null : const BoxConstraints(maxWidth: 700),
          margin: EdgeInsets.only(
            bottom: widget.mini ? 0 : 30,
          ),
          decoration: BoxDecoration(
            color: $styles.colors.secondaryColor.withOpacity(.2),
            // boxShadow: $styles.shadows.boxShadowSmall,
          ),
        ),
      ],
    );
  }
}
