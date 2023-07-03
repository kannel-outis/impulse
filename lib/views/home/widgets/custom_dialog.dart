import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/impulse_scaffold.dart';
import 'package:lottie/lottie.dart';

class CustomDialog extends ConsumerStatefulWidget {
  const CustomDialog({
    super.key,
  });

  @override
  ConsumerState<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends ConsumerState<CustomDialog> {
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
      child: Dialog(
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
      ),
    );
  }
}
