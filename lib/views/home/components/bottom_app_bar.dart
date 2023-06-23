import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

import '../widgets/bottom_app_bar_icon.dart';

class MyBottomAppBar extends StatefulWidget {
  final int startIndex;
  const MyBottomAppBar({
    super.key,
    this.startIndex = 0,
  });

  @override
  State<MyBottomAppBar> createState() => _MyBottomAppBarState();
}

class _MyBottomAppBarState extends State<MyBottomAppBar> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.startIndex;
  }

  List<(IconData, IconData)> get bars => const [
        (ImpulseIcons.bx_home_alt_2, ImpulseIcons.bxs_home_alt_2),
        (ImpulseIcons.bx_folder, ImpulseIcons.bxs_folder),
        (ImpulseIcons.bx_cog, ImpulseIcons.bxs_cog),
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: $styles.shadows.boxShadowSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < bars.length; i++)
            InkWell(
              highlightColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              onTap: () {
                index = i;
                setState(() {});
              },
              child: AnimatedSwitcher(
                duration: $styles.times.fast,
                reverseDuration: $styles.times.pageTransition,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: index == i
                    ? BottomAppBarIcon(
                        key: ValueKey(index == i),
                        icon: bars[i].$2,
                        color: $styles.colors.iconColor2,
                      )
                    : BottomAppBarIcon(
                        key: ValueKey(index == i),
                        icon: bars[i].$1,
                        color: null,
                      ),
              ),
            )
        ],
      ),
    );
  }
}
