import 'package:flutter/material.dart';

class Sizer extends StatefulWidget {
  final Function(Size)? onSize;
  final Widget child;
  const Sizer({
    Key? key,
    this.onSize,
    required this.child,
  }) : super(key: key);

  @override
  State<Sizer> createState() => _SizerState();
}

class _SizerState extends State<Sizer> with WidgetsBindingObserver {
  final key = GlobalKey();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(postFrame);
  }

  void postFrame(Duration timestamp) {
    final size = key.currentContext?.size;
    if (size != null) {
      widget.onSize?.call(size);
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback(postFrame);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: key,
      child: widget.child,
    );
  }
}
