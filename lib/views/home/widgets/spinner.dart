import 'dart:math';

import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

import 'transfer_painter.dart';

class Spinner extends StatefulWidget {
  final Widget? child;
  final double? size;
  final Color? color;
  final bool spin;
  const Spinner({
    super.key,
    this.child,
    this.size,
    this.color,
    this.spin = false,
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
    if (widget.spin == true) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant Spinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spin != oldWidget.spin) {
      if (widget.spin == true) {
        _controller.stop();
        _controller.repeat();
      } else {
        _controller.reset();
      }
      setState(() {});
    }
    if (widget.size != oldWidget.size || widget.color != oldWidget.color) {
      setState(() {});
    }
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
                size: Size(widget.size ?? 40, widget.size ?? 40),
                painter: TransferPainter(
                  color: widget.color ?? $styles.colors.fontColor1,
                  weight: 1.5,
                ),
              ),
            );
          },
        ),
        widget.child ??
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
