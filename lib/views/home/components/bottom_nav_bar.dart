import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

import '../widgets/bottom_app_bar_icon.dart';

class MyBottomNavBar extends StatefulWidget {
  final int index;
  final Map<String, (IconData, IconData)> bars;
  final Function(int)? onChanged;
  const MyBottomNavBar({
    super.key,
    this.index = 0,
    required this.bars,
    this.onChanged,
  });

  @override
  State<MyBottomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.index;
  }

  @override
  void didUpdateWidget(covariant MyBottomNavBar oldWidget) {
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
          for (var i = 0; i < widget.bars.length; i++)
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
                        icon: widget.bars.values.toList()[i].$2,
                        color: Theme.of(context).colorScheme.primary,
                        label: widget.bars.keys.toList()[i],
                      )
                    : BottomAppBarIcon(
                        key: ValueKey(index == i),
                        icon: widget.bars.values.toList()[i].$1,
                        color: Theme.of(context).colorScheme.tertiary,
                        label: widget.bars.keys.toList()[i],
                      ),
              ),
            )
        ],
      ),
    );
  }
}
