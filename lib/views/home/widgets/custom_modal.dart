import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/impulse_scaffold.dart';
import 'package:lottie/lottie.dart';

import 'scan_animation_painter.dart';

class CustomHostBottomModalSheet extends ConsumerStatefulWidget {
  const CustomHostBottomModalSheet({
    super.key,
  });

  @override
  ConsumerState<CustomHostBottomModalSheet> createState() =>
      _CustomHostBottomModalSheetState();
}

class _CustomHostBottomModalSheetState
    extends ConsumerState<CustomHostBottomModalSheet> {
  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final homeController = ref.watch(homeProvider);

    return WillPopScope(
      onWillPop: () async {
        homeController.shouldShowTopStack = true;

        return true;
      },
      child: ImpulseScaffold(
        child: Container(
          height: $styles.sizes.maxContentHeight1,
          width: double.infinity,
          color: $styles.colors.accentColor1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(
              //   Icons.wifi_tethering,
              //   color: $styles.colors.iconColor3,
              //   size: $styles.sizes.xLargeIconSize,
              // ),
              LottieBuilder.asset(
                "assets/lottie/waiting.json",
                height: $styles.sizes.xxLargeIconSize,
                width: $styles.sizes.xxLargeIconSize,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(
                      ['bout', 'bout 3', 'bmid'],
                      callback: (s) {
                        print(s);

                        return Color(0xff78ee34);
                      },
                    )
                  ],
                ),
              ),
              Text(
                "Waitng for receivers....",
                style: $styles.text.h3,
              ),
            ],
          ),
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

  @override
  void initState() {
    super.initState();
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
      },
    );
    // _scan(count: 40);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scanTick?.cancel();
    super.dispose();
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
          if (MediaQuery.of(context).size.width > modalConstraints.maxWidth) {
            return modalConstraints.maxWidth;
          } else {
            return MediaQuery.of(context).size.width;
          }

          ///add padding
        }() -
        50;

    ///add padding
    final height = modalConstraints.maxHeight - 50;
    final offset = Offset(
      random.nextInt(width.toInt()).toDouble(),
      random.nextInt(height.toInt()).toDouble(),
    );
    return offset;
  }

  @override
  Widget build(BuildContext context) {
    final clientController = ref.watch(clientProvider);

    return ImpulseScaffold(
      child: Container(
        height: $styles.sizes.maxContentHeight1,
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
            // for (var i = 0;
            //     i < clientController.availableHostServers.length;
            //     i++)
            // Positioned(
            //   top: randomOffsets[i].dy,
            //   left: randomOffsets[i].dx,
            //   child: Container(
            //     height: 50,
            //     width: 50,
            //     decoration: BoxDecoration(
            //       image: DecorationImage(
            //         image: MemoryImage(
            //           clientController
            //               .availableHostServers[i].user.displayImage,
            //         ),
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  ////Scan for a particular time
  Future<bool> _scan({int? count}) async {
    Completer<bool> completer = Completer<bool>();
    final clientController = ref.read(clientProvider);
    clientController.clearAvailableUsers();
    Timer.periodic(
      const Duration(seconds: 1),
      (tick) async {
        _scanTick = tick;
        await clientController.getAvailableUsers();

        if (tick.tick == (count ?? 3)) {
          tick.cancel();
          if (ref.read(clientProvider).availableHostServers.isNotEmpty) {
            completer.complete(true);
          } else {
            completer.complete(false);
          }
        }
      },
    );
    return await completer.future;
  }
}
