import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:lottie/lottie.dart';

import '../widgets/scan_animation_painter.dart';

class CustomHostBottomModalSheet extends ConsumerStatefulWidget {
  const CustomHostBottomModalSheet({
    super.key,
  });

  @override
  ConsumerState<CustomHostBottomModalSheet> createState() =>
      _CustomHostBottomModalSheetState();
}

class _CustomHostBottomModalSheetState
    extends ConsumerState<CustomHostBottomModalSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: $styles.times.xSlow);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final homeController = ref.read(homeProvider);
      final hostController = ref.read(senderProvider);
      hostController.createServer().then((value) {
        homeController.isWaitingForReceiver = true;
        ref.read(userTypeProvider.notifier).setUserState(UserType.host);
        // print(hostController.clientServerInfo);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final homeController = ref.read(homeProvider);

      homeController.shouldShowTopStack = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeController = ref.watch(homeProvider);

    return WillPopScope(
      onWillPop: () async {
        homeController.shouldShowTopStack = true;

        return true;
      },
      child: Container(
        height: $styles.sizes.maxContentHeight1,
        width: double.infinity,
        color: $styles.colors.accentColor1,
        constraints: $styles.constraints.modalConstraints,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(
            //   Icons.wifi_tethering,
            //   color: $styles.colors.iconColor3,
            //   size: $styles.sizes.xLargeIconSize,
            // ),
            Lottie(
              composition: Configurations.instance.composition,
              height: $styles.sizes.xxLargeIconSize,
              width: $styles.sizes.xxLargeIconSize,
              controller: _controller..repeat(),
              fit: BoxFit.contain,
            ),
            // } else {
            //   return const Center(
            //     child: CircularProgressIndicator(),
            //   );
            // }
            // return LottieBuilder.asset(
            //   "assets/lottie/waiting.json",
            //   height: $styles.sizes.xxLargeIconSize,
            //   width: $styles.sizes.xxLargeIconSize,
            //   controller: _controller,
            //   frameRate: FrameRate.max,
            //   frameBuilder: (context, child, composition) {
            //     return child;
            //   },
            //   // delegates: LottieDelegates(
            //   //     // values: [
            //   //     //   ValueDelegate.color(
            //   //     //     ['bout', 'bout 3', 'bmid'],
            //   //     //     callback: (s) {

            //   //     //       return Color(0xff78ee34);
            //   //     //     },
            //   //     // )
            //   //     // ],
            //   //     ),
            // );
            // }),
            Text(
              "Waitng for receivers....",
              style: $styles.text.h3,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomClientBottomModalSheet extends ConsumerStatefulWidget {
  const CustomClientBottomModalSheet({super.key});

  @override
  ConsumerState<CustomClientBottomModalSheet> createState() =>
      _CustomClientBottomModalSheetState();
}

class _CustomClientBottomModalSheetState
    extends ConsumerState<CustomClientBottomModalSheet>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  List<Offset> randomOffsets = [];
  List<Color> colors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.pink,
    Colors.blue,
    Colors.green,
    Colors.grey
  ];
  final GlobalKey _parentStackKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();
  Timer? _scanTick = null;

  double get _modalInnerPadding => 50.0;

  int called = 0;

  @override
  void initState() {
    super.initState();
    ref.read(receiverProvider).clearAvailableUsers();
    _animationController = AnimationController(
      vsync: this,
      duration: $styles.times.slow,
    );
    _animationController.repeat();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        for (var i = 0; i < 7; i++) {
          randomOffsets
              .add(checkIfOffsetOccupied(randomOffset(context), context));
        }
        setState(() {});
        // print();
      },
    );
    _scan(count: 5);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scanTick?.cancel();
    super.dispose();
  }

  ////Scan for a particular time
  Future<bool> _scan({int? count}) async {
    int calledNumOf = 1;
    Completer<bool> completer = Completer<bool>();
    final clientController = ref.read(receiverProvider);
    clientController.clearAvailableUsers();
    _scanTick = Timer.periodic(
      const Duration(seconds: 3),
      (tick) async {
        if (calledNumOf == (count ?? 3)) {
          tick.cancel();
          if (!tick.isActive) {
            if (ref.read(receiverProvider).availableHostServers.isNotEmpty) {
              completer.complete(true);
            } else {
              completer.complete(false);
            }
            return;
          }
        } else {
          calledNumOf++;
          await clientController.getAvailableUsers();
        }
      },
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    // final receiverController = ref.watch(receiverProvider);

    return Container(
      height: $styles.constraints.modalConstraints.maxHeight,
      width: double.infinity,
      color: $styles.colors.accentColor1,
      child: Stack(
        key: _parentStackKey,
        alignment: Alignment.center,
        // fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScanCustomPainter(
                    _animationController,

                    ///
                    setPosition: 15,
                  ),
                );
              },
            ),
          ),
          Positioned(
            /// -(half of container size) + setPosition
            /// it gives the perfect animation position
            /// e.g: -(70/2) + 15 == -20
            bottom: -20,
            child: Container(
              key: _searchKey,
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($styles.corners.xxlg),
                color: $styles.colors.secondaryColor,
              ),
              child: Center(
                child: Icon(
                  Icons.search,
                  color: $styles.colors.iconColor1,
                  size: $styles.sizes.smallIconSize2,
                ),
              ),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final receiverController = ref.watch(receiverProvider);

              return Stack(
                children: [
                  for (var i = 0;
                      i < receiverController.availableHostServers.length;
                      i++)
                    Align(
                      // top: randomOffsets[i].dy,
                      // left: randomOffsets[i].dx,
                      alignment: _convertOffsetToAlignment(randomOffsets.last,
                          $styles.sizes.modalBoxSize, context),
                      child: GestureDetector(
                        onTap: () async {
                          final provider = ref.read(receiverProvider);
                          provider.selectHost(
                              receiverController.availableHostServers[i]);
                          final result =
                              await provider.createServerAndNotifyHost();
                          if (result == null) {
                            ref
                                .read(userTypeProvider.notifier)
                                .setUserState(UserType.client);
                            ref.read(homeProvider).shouldShowTopStack = true;
                          }
                        },
                        child: SizedBox(
                          height: _modalInnerPadding + 30.scale,
                          width: _modalInnerPadding + 20.scale,
                          // color: Colors.yellow,
                          child: Column(
                            children: [
                              Container(
                                height: _modalInnerPadding,
                                width: _modalInnerPadding,
                                decoration: BoxDecoration(
                                  color: colors[i],
                                  borderRadius:
                                      BorderRadius.circular($styles.corners.lg),
                                  image: DecorationImage(
                                    image: MemoryImage(
                                      receiverController.availableHostServers[i]
                                          .user.displayImage,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              FittedBox(
                                child: Text(
                                  receiverController
                                      .availableHostServers[i].user.name,
                                  style: $styles.text.body,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Offset _getSearchIconOffset() {
    final searchBox =
        _searchKey.currentContext!.findRenderObject() as RenderBox;
    final parentStack =
        _parentStackKey.currentContext!.findRenderObject() as RenderBox;

    ///find global offset of the search container since we cant directly find localoffset
    final localOffset = searchBox.localToGlobal(Offset.zero);

    ///find local offset of the search container using the parent which is stack
    return parentStack.globalToLocal(localOffset);
  }

  Offset checkIfOffsetOccupied(Offset offset, BuildContext context) {
    final searchOffset = _getSearchIconOffset();
    final contains = randomOffsets.where((element) {
      /// box size + margin
      final rect = element.contains(offset, 50 + 20);
      return rect;
    });

    //// makes sure that it doesnt appear on the seacrh icon
    ///The search icon conatiner size is 70
    if (contains.isEmpty && !searchOffset.contains(offset, 70)) {
      return offset;
    } else {
      return checkIfOffsetOccupied(randomOffset(context), context);
    }
  }

  Offset randomOffset(BuildContext context) {
    final random = Random();
    final modalConstraints = BoxConstraints(
      maxWidth: $styles.sizes.maxContentWidth1,
      maxHeight: $styles.sizes.maxContentHeight1,
    );

    /// for large devices like desktop whose modal sheets dont take the whole width
    final double width = () {
          // return MediaQuery.of(context).size.width;
          // return modalConstraints.maxWidth;
          if (MediaQuery.of(context).size.width > modalConstraints.maxWidth) {
            return modalConstraints.maxWidth;
          } else {
            return MediaQuery.of(context).size.width;
          }

          ///add padding
        }() -
        _modalInnerPadding;

    ///add padding
    final height = modalConstraints.maxHeight - _modalInnerPadding;
    final offset = Offset(
      random.nextInt(width.toInt()).toDouble(),
      random.nextInt(height.toInt()).toDouble(),
    );
    return offset;
  }

  Alignment _convertOffsetToAlignment(Offset offset, Size size, context) {
    ///add the padding to the size
    double width = 0.0;

    if (MediaQuery.of(context).size.width > size.width) {
      width = size.width;
    } else {
      width = MediaQuery.of(context).size.width;
    }
    // width = (size.width / 2) - _modalInnerPadding;
    // print(MediaQuery.of(context).size.width);
    final height = (size.height - _modalInnerPadding);
    final x = (offset.dx / (width / 2)) - 1;
    final y = (offset.dy / (height / 2)) - 1;
    final s = Alignment(x, y);
    return s;
  }
}
