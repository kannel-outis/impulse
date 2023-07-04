import 'package:flutter/material.dart';
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
          height: 300,
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: $styles.times.slow,
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ImpulseScaffold(
      child: Container(
        height: 300,
        width: double.infinity,
        color: $styles.colors.accentColor1,
        child: Stack(
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
            )
          ],
        ),
      ),
    );
  }
}
