// ignore_for_file: library_private_types_in_public_api

///modifer version of https://github.com/kannel-outis/Flash_Youtube/blob/dev-2/flash_youtube_downloader/lib/screens/mini_player/components/mini_player_draggable.dart

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/services/services.dart';

import 'widgets/full_transfer_page.dart';
import 'widgets/transfer_list_tile.dart';

class TransferPage extends ConsumerStatefulWidget {
  const TransferPage({super.key});

  @override
  ConsumerState<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends ConsumerState<TransferPage> {
  @override
  Widget build(BuildContext context) {
    return MiniPlayer(
      miniPlayerController: ref.watch(miniPlayerController),
      // collapseChild: Container(),
    );
  }
}

class MiniPlayer extends StatefulWidget {
  final _MiniPlayerController miniPlayerController;
  final Widget? child;
  final Widget? playerChild;
  final Widget? collapseChild;
  final Function(double)? percentage;
  final Widget? bottomCollapseChild;
  const MiniPlayer({
    Key? key,
    this.child,
    this.percentage,
    this.playerChild,
    this.collapseChild,
    this.bottomCollapseChild,
    required this.miniPlayerController,
  }) : super(key: key);

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with TickerProviderStateMixin {
  late final AnimationController _controller;
  // late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // _scrollController = ScrollController();
    widget.miniPlayerController._playerState = this;
    widget.miniPlayerController._setInitialized();
    final range = widget.miniPlayerController.maxHeight -
        widget.miniPlayerController.minHeight;
    final value = () {
      if (widget.miniPlayerController.startOpen != null &&
          widget.miniPlayerController.startOpen == true) {
        return 1.0;
      } else {
        return 0.0;
      }
    }();
    _controller = AnimationController(
      vsync: this,
      duration: widget.miniPlayerController.animationDuration,
      value: value,
    )..addListener(() {
        final value = _calCulateSizeWithController(
          widget.miniPlayerController.minHeight,
          widget.miniPlayerController.maxHeight,
        );
        final dragRange = value - widget.miniPlayerController.minHeight;
        final percentage = (dragRange * 100) / range;
        widget.percentage?.call(percentage);
      });
  }

  @override
  void didUpdateWidget(covariant MiniPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.miniPlayerController._playerState = this;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double calcBottomAlignment(BuildContext context) {
    final height = MediaQuery.of(context).size.height / 2;
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    final bottomHeight = () {
      if (bottomInsets != 0.0) {
        return bottomInsets;
      } else {
        return kBottomNavigationBarHeight;
      }
    }();
    final bottomNavBarHeightPercent =
        ((height - (bottomHeight * 1.3)) / height) * 100;
    return bottomNavBarHeightPercent / 100;
  }

  double calcBottomAlignmentToOneDP(BuildContext context) {
    return calcBottomAlignment(context);
  }

  @override
  Widget build(BuildContext context) {
    final isPotrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return AnimatedAlign(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment(
        0,
        calcBottomAlignmentToOneDP(context),
      ),
      // alignment:
      //     isPotrait ? const Alignment(.85, .85) : const Alignment(.85, .65),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              // border: Border.all(
              //   color: Colors.white.withOpacity(1 - _controller.value),
              //   width: 1.5,
              // ),
            ),
            height: _calCulateSizeWithController(
              isPotrait
                  ? widget.miniPlayerController.minHeight
                  : widget.miniPlayerController.landScapeMinHeight,
              widget.miniPlayerController.maxHeight,
            ),
            width: MediaQuery.of(context).size.width,
            // color: Colors.white,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragEnd: (e) async {
                await widget.miniPlayerController._handleDragEnd(e);
              },
              onVerticalDragUpdate: (e) {
                widget.miniPlayerController._handleDragUpdate(e);
              },
              child: SingleChildScrollView(
                child: _controller.value <= .04
                    ? GestureDetector(
                        onTap: widget.miniPlayerController.openMiniPlayer,
                        child: widget.collapseChild ??
                            Consumer(
                              builder: (context, ref, child) {
                                final downloadManager =
                                    ref.watch(downloadManagerProvider);
                                final uploadManager =
                                    ref.watch(uploadManagerProvider);
                                /* 
                                    ! This needs to be here to start listening to the provider
                                    ! it serves as the first listener to the receivableItems after a connection has been established
                                    ! This makes sure the listener that listens to the receivable stream controller is triggered
                                    ! that way, it can automatically start downloading the items
                                    */
                                ref.watch(receivableListItems);
                                if (downloadManager.currentDownload != null &&
                                    downloadManager
                                        .currentDownload!.state.isInProgress) {
                                  log(downloadManager.mBps);
                                  return TransferListTile(
                                    item: downloadManager.currentDownload!,
                                    mini: true,
                                    mBps: ImpulseFileSize(downloadManager.mBps)
                                        .sizeToString,
                                    height:
                                        widget.miniPlayerController.minHeight,
                                  );
                                } else if (uploadManager.currentDownload !=
                                    null) {
                                  return TransferListTile(
                                    item: uploadManager.currentDownload!,
                                    mini: true,
                                    mBps: ImpulseFileSize(uploadManager.mBps)
                                        .sizeToString,
                                    height:
                                        widget.miniPlayerController.minHeight,
                                  );
                                } else {
                                  return Container(
                                    height:
                                        widget.miniPlayerController.minHeight,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                          width: .5,
                                        ),
                                        // bottom: BorderSide(
                                        //   color: Colors.white,
                                        //   width: 1,
                                        // ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "No Shared Item yet",
                                        style: $styles.text.body,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                      )
                    : const FullTransferPage(),
              ),
            ),
          );
        },
      ),
    );
  }

  double _calCulateSizeWithController(
    double minSize,
    double maxSize, {
    double valueMultiplier = 1,
  }) {
    final result =
        lerpDouble(minSize, maxSize, _controller.value * valueMultiplier)!;
    return result;
  }

  // ignore: unused_element
  void _toggleOpenClodePanel() {
    final bool isOpen = _controller.status == AnimationStatus.completed;
    // _controller.fling(velocity: isOpen ? -1 : 1);
    if (isOpen) {
      widget.miniPlayerController.closeMiniPlayer();
    } else {
      widget.miniPlayerController.openMiniPlayer();
      setState(() {});
    }
  }
}

class TabWidget extends StatelessWidget {
  const TabWidget({
    super.key,
    required this.items,
    required this.label,
  });

  final List<Item> items;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: MediaQuery.of(context).size.width < 250
          ? Axis.vertical
          : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          label,
          style: $styles.text.body,
        ),
        if (items.isNotEmpty)
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($styles.corners.xxlg),
                color: Theme.of(context).colorScheme.surface),
            child: Center(
              child: Text(
                "${items.where((element) => !element.state.isCompleted).toList().length}",
                style: $styles.text.bodySmall.copyWith(
                  height: 1.5,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
          )
      ],
    );
  }
}

final miniPlayerController = ChangeNotifierProvider(
  (ref) => _MiniPlayerController(
    minHeight: 70,
    maxHeight: $styles.screenSize.height,
    landScapeMinHeight: 50,
    startOpen: false,
  ),
);

class _MiniPlayerController extends ChangeNotifier {
  final double minHeight;
  final double maxHeight;
  final double landScapeMinHeight;
  final bool? startOpen;
  final Duration animationDuration;

  _MiniPlayerController({
    required this.minHeight,
    required this.maxHeight,
    required this.landScapeMinHeight,
    this.startOpen,
    // ignore: unused_element
    this.animationDuration = const Duration(milliseconds: 300),
  }) : _isClosed = !startOpen!;

  _MiniPlayerState? _playerState;

  // ignore: unused_element
  factory _MiniPlayerController.nil() {
    return _MiniPlayerController(
      minHeight: 0,
      maxHeight: 0,
      startOpen: true,
      landScapeMinHeight: 0,
    );
  }

  bool _initialized = false;
  bool get initialized => _initialized;
  @protected
  _MiniPlayerState? get playerState => _playerState;
  // ignore: avoid_setters_without_getters
  set setPlayerState(_MiniPlayerState? state) {
    _playerState = state;
  }

  void _setInitialized() {
    _initialized = true;
  }

  bool? _isClosed;
  bool get isClosed => _isClosed ?? true;

  void closeMiniPlayer() {
    _playerState?._controller.reverse();
    _isClosed = true;
    notifyListeners();
  }

  void openMiniPlayer() {
    _playerState?._controller.forward();
    _isClosed = false;
    notifyListeners();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _playerState?._controller.value -= details.primaryDelta! / maxHeight;
    // notifyListeners();
    // print(_playerState!._calCulateSizeWithController(minHeight, maxHeight));
  }

  Future<void> _handleDragEnd(DragEndDetails details) async {
    if (_playerState!._controller.isAnimating ||
        _playerState?._controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / maxHeight;
    if (flingVelocity < 0.0) {
      await _playerState?._controller.fling(velocity: max(1.0, -flingVelocity));
      _isClosed = false;
    } else if (flingVelocity > 0.0) {
      await _playerState?._controller
          .fling(velocity: min(-1.0, -flingVelocity));
      _isClosed = true;
    } else {
      await _playerState?._controller
          .fling(velocity: _playerState!._controller.value < 0.5 ? -1.0 : 1.0);
      if (_playerState!._controller.value < 0.5) {
        _isClosed = true;
      } else {
        _isClosed = false;
      }
    }
    // notifyListeners();
  }
}
