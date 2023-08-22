import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

class SpeedChild extends StatelessWidget {
  final bool isHost;
  final VoidCallback? onTap;
  final IconData icon;
  final double additionalIconSize;
  final bool disableDefaultFunc;
  const SpeedChild({
    super.key,
    required this.icon,
    this.onTap,
    this.isHost = true,
    this.disableDefaultFunc = false,
    this.additionalIconSize = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isHost ? "Send" : "Receive",
      textStyle: $styles.text.bodySmall.copyWith(
        color: $styles.colors.accentColor1,
      ),
      preferBelow: false,
      verticalOffset: 30,
      triggerMode:
          isAndroid ? TooltipTriggerMode.longPress : TooltipTriggerMode.manual,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            // if (isHost == false) {
            //   showModalBottomSheet(
            //       context: context,
            //       useRootNavigator: false,
            //       useSafeArea: true,
            //       builder: (context) {
            //         return CustomDialog();
            //       });
            //   return;
            // }

            onTap?.call();
            if (!disableDefaultFunc) showModel(isHost, context);
          },
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Icon(
              icon,
              size: 20 + additionalIconSize,
            ),
          ),
        ),
      ),
    );
  }
}
