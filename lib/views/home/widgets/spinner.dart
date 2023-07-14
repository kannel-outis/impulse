import 'dart:math';

import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

import 'transfer_painter.dart';

class Spinner extends StatefulWidget {
  const Spinner({
    super.key,
  });

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: (_controller.value * 2 * pi),
              child: CustomPaint(
                size: Size(70.scale, 70.scale),
                painter: TransferPainter(
                  color: $styles.colors.fontColor1,
                  weight: 1.5,
                ),
              ),
            );
          },
        ),
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: $styles.colors.secondaryColor,
            borderRadius: BorderRadius.circular(100),
          ),
          // child: RotatedBox(
          //   quarterTurns: 1,
          //   child: Icon(
          //     Icons.sync_alt_rounded,
          //   ),
          // ),
        ),
      ],
    );
  }
}
