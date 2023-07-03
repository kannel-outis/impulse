import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

class CustomSpeedDial extends StatefulWidget {
  final Duration duration;
  final List<Widget> children;
  final Widget child;
  final double childSpacing;
  final Function(bool)? onToggle;
  final Offset overlayChildrenOffset;
  final bool open;
  final bool? disable;
  const CustomSpeedDial({
    super.key,
    required this.children,
    required this.child,
    this.onToggle,
    this.open = false,
    this.overlayChildrenOffset = Offset.zero,
    this.childSpacing = .3,
    this.duration = const Duration(milliseconds: 500),
    this.disable = false,
  });

  @override
  State<CustomSpeedDial> createState() => _CustomSpeedDialState();
}

class _CustomSpeedDialState extends State<CustomSpeedDial>
    with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late final AnimationController _animationController;
  final LayerLink _layerLink = LayerLink();

  @override
  void didUpdateWidget(covariant CustomSpeedDial oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.childSpacing != oldWidget.childSpacing ||
        widget.children.length != oldWidget.children.length ||
        widget.overlayChildrenOffset != oldWidget.overlayChildrenOffset) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _overlayEntry?.markNeedsBuild();
      });
    }
    if (widget.duration != oldWidget.duration) {
      _animationController.duration = widget.duration;
    }

    if (widget.open != _isOpen) {
      _toggleOverlay(context, close: widget.open);
    }
  }

  @override
  void reassemble() {
    super.reassemble();

    _overlayEntry?.markNeedsBuild();
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _toggleOverlay(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Tooltip(
        message: "Connect",
        verticalOffset: -70,
        textStyle: $styles.text.body.copyWith(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        decoration: BoxDecoration(
          color: $styles.colors.fontColor1,
          borderRadius: BorderRadius.circular($styles.corners.sm),
        ),
        waitDuration: $styles.times.slow,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            // borderRadius: widget.borderRadius ?? BorderRadius.zero,
            onTap: widget.disable!
                ? null
                : () {
                    _toggleOverlay(context);
                  },
            child: widget.child,
          ),
        ),
      ),
    );
  }

  // OverlayEntry _createOverlayEntry(BuildContext context) {
  //   return OverlayEntry(builder: builder);
  // }

  Curve _interval(int i) {
    return Interval(
      i * 0.1,
      (i * 0.1) + .4,
      curve: $styles.curves.defaultCurve,
    );
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    // print(size);
    final size = MediaQuery.of(context).size;
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () => _toggleOverlay(context, close: true),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < widget.children.length; i++)
                CompositedTransformFollower(
                  link: _layerLink,
                  offset: widget.overlayChildrenOffset,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      end: Offset(0, (-i * (1 + widget.childSpacing)) - 1),
                      begin: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: _interval(i),
                      ),
                    ),
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0,
                        end: 1,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: _interval(i),
                        ),
                      ),
                      child: FadeTransition(
                          opacity: Tween<double>(
                            begin: 0,
                            end: 1,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: _interval(i),
                            ),
                          ),
                          child: widget.children[i]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleOverlay(
    BuildContext context, {
    bool close = false,
  }) async {
    if (_isOpen || close) {
      await _animationController.reverse();
      _overlayEntry?.remove();
      setState(() => _isOpen = false);
      widget.onToggle?.call(false);
    } else {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
      setState(() => _isOpen = true);
      await _animationController.forward();
      widget.onToggle?.call(true);
    }
  }
}
