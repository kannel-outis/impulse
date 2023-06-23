import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

import '../widgets/bottom_app_bar_icon.dart';

class MyBottomAppBar extends StatefulWidget {
  final int index;
  final Function(int)? onChanged;
  const MyBottomAppBar({
    super.key,
    this.index = 0,
    this.onChanged,
  });

  @override
  State<MyBottomAppBar> createState() => _MyBottomAppBarState();
}

class _MyBottomAppBarState extends State<MyBottomAppBar> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.index;
  }

  Map<String, (IconData, IconData)> get bars => const {
        "Home": (ImpulseIcons.bx_home_alt_2, ImpulseIcons.bxs_home_alt_2),
        "Files": (ImpulseIcons.bx_folder, ImpulseIcons.bxs_folder),
        "Settings": (ImpulseIcons.bx_cog, ImpulseIcons.bxs_cog),
      };

  @override
  void didUpdateWidget(covariant MyBottomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      index = widget.index;
    }
  }

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
                widget.onChanged?.call(index);
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
                        icon: bars.values.toList()[i].$2,
                        color: $styles.colors.iconColor2,
                        label: bars.keys.toList()[i],
                      )
                    : BottomAppBarIcon(
                        key: ValueKey(index == i),
                        icon: bars.values.toList()[i].$1,
                        color: null,
                        label: bars.keys.toList()[i],
                      ),
              ),
            )
        ],
      ),
    );
  }
}
