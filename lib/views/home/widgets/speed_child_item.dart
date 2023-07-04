import 'package:flutter/material.dart';

import 'custom_modal.dart';

class SpeedChild extends StatelessWidget {
  final bool isHost;
  final VoidCallback? onTap;
  final IconData icon;
  const SpeedChild({
    super.key,
    required this.icon,
    this.onTap,
    this.isHost = true,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onTap?.call();
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

          showModalBottomSheet(
            context: context,
            builder: (context) {
              if (isHost) {
                return const CustomHostBottomModalSheet();
              }
              return const CustomClientBottomModalSheet();
            },
          );
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
            size: 25,
          ),
        ),
      ),
    );
  }
}
