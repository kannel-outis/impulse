import 'package:flutter/cupertino.dart' hide ConnectionState;
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/views/home/widgets/spinner.dart';

class TopStack extends ConsumerStatefulWidget {
  const TopStack({
    super.key,
  });

  @override
  ConsumerState<TopStack> createState() => _TopStackState();
}

class _TopStackState extends ConsumerState<TopStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: $styles.times.med,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    final isConnected = connectionState == ConnectionState.connected;
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: $styles.curves.defaultCurve,
        ),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {},
          child: Spinner(
            size: 35,
            spin: isConnected,
            color: isConnected ? Colors.green : $styles.colors.iconColor3,
            child: AnimatedContainer(
              duration: $styles.times.fast,
              // height: 25,
              // width: 25,
              decoration: BoxDecoration(
                // color: isConnected ? Colors.green : $styles.colors.iconColor3,
                borderRadius: BorderRadius.circular(100),
              ),
              child: SizedBox(
                child: SvgPicture.asset(
                  AssetsImage.wifi,
                  height: 20,
                  width: 20,
                  theme: SvgTheme(
                    currentColor:
                        isConnected ? Colors.green : $styles.colors.iconColor3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
