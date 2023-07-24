// ignore_for_file: library_private_types_in_public_api

///modifer version of https://github.com/kannel-outis/Flash_Youtube/blob/dev-2/flash_youtube_downloader/lib/screens/mini_player/components/mini_player_draggable.dart

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/services/services.dart';

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
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);
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
                                final shareable =
                                    ref.watch(shareableItemsProvider);
                                final downloadManager =
                                    ref.watch(downloadManagerProvider);
                                if (downloadManager.$2 != null) {
                                  log(downloadManager.$1);
                                  return TransferListTile(
                                    item: downloadManager.$2!,
                                    mini: true,
                                    mBps: ImpulseFileSize(downloadManager.$1)
                                        .sizeToString,
                                    height:
                                        widget.miniPlayerController.minHeight,
                                  );
                                }

                                if (shareable.isEmpty) {
                                  return Container(
                                    height:
                                        widget.miniPlayerController.minHeight,
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.white,
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
                                final inProgressItemsWidget = shareable
                                    .where((element) =>
                                        element.state == IState.inProgress)
                                    .toList()
                                    .map(
                                      (e) => TransferListTile(
                                        height: widget
                                            .miniPlayerController.minHeight,
                                        mini: true,
                                        item: e,
                                      ),
                                    )
                                    .toList();
                                return inProgressItemsWidget.isEmpty
                                    ? TransferListTile(
                                        item: shareable.last,
                                        mini: true,
                                        height: widget
                                            .miniPlayerController.minHeight,
                                      )
                                    : inProgressItemsWidget.first;
                              },
                            ),
                      )
                    : SizedBox(
                        height: $styles.screenSize.height -
                            View.of(context).padding.top,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 200,
                              width: double.infinity,
                              color: $styles.colors.secondaryColor,
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                children: [
                                  Expanded(child: Container()),
                                  SizedBox(
                                    width: 250,
                                    child: TabBar(
                                      controller: _tabController,
                                      indicatorSize: TabBarIndicatorSize.label,
                                      labelPadding: EdgeInsets.only(
                                        bottom: $styles.insets.xs,
                                        right: $styles.insets.md,
                                        top: $styles.insets.sm,
                                      ),
                                      splashFactory: NoSplash.splashFactory,
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.transparent),
                                      indicatorColor: $styles.colors.fontColor1,
                                      labelColor: $styles.colors.fontColor1,
                                      indicatorWeight: 2,
                                      padding: EdgeInsets.zero,
                                      tabs: [
                                        Consumer(builder: (contex, ref, child) {
                                          final shareables =
                                              ref.watch(shareableItemsProvider);
                                          return TabWidget(
                                              label: "Sent", items: shareables);
                                        }),
                                        Consumer(
                                            builder: (context, ref, child) {
                                          final receaivables =
                                              ref.watch(receivableListItems);
                                          return TabWidget(
                                              label: "Received",
                                              items: receaivables);
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final shareable =
                                          ref.watch(shareableItemsProvider);
                                      return ListView(
                                        ///size of each tile and margin
                                        physics: ((100 + $styles.insets.lg) *
                                                    shareable.length >
                                                MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    200)
                                            ? const AlwaysScrollableScrollPhysics()
                                            : const NeverScrollableScrollPhysics(),
                                        children: [
                                          ...List.generate(
                                            shareable.length,
                                            (index) => TransferListTile(
                                                item: shareable[index]),
                                          ).reversed,
                                        ],
                                      );
                                    },
                                  ),
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final receivables =
                                          ref.watch(receivableListItems);
                                      return ListView(
                                        physics: ((100 + $styles.insets.lg) *
                                                    receivables.length >
                                                MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    200)
                                            ? const AlwaysScrollableScrollPhysics()
                                            : const NeverScrollableScrollPhysics(),
                                        children: [
                                          ...List.generate(
                                            receivables.length,
                                            (index) => TransferListTile(
                                                item: receivables[index]),
                                          ).reversed,
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
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
                color: $styles.colors.fontColor1),
            child: Center(
              child: Text(
                "${items.length}",
                style: $styles.text.bodySmall.copyWith(
                  height: 1.5,
                  color: $styles.colors.accentColor1,
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
    this.animationDuration = const Duration(milliseconds: 300),
  }) : _isClosed = startOpen!;

  _MiniPlayerState? _playerState;

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
