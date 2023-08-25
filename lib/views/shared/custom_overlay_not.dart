import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';

class CustomOverlayNot extends ConsumerStatefulWidget {
  final Widget child;
  const CustomOverlayNot({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<CustomOverlayNot> createState() => _CustomOverlayNotState();
}

class _CustomOverlayNotState extends ConsumerState<CustomOverlayNot>
    with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late final AnimationController _animationController;
  final LayerLink _layerLink = LayerLink();

  @override
  void didUpdateWidget(covariant CustomOverlayNot oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void reassemble() {
    super.reassemble();

    _overlayEntry?.markNeedsBuild();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = ref.watch(homeProvider);
    provider.addListener(() {
      if (provider.isWaitingForReceiver == true) {
        _toggleOverlay(context, close: false, forceClose: false);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: $styles.times.med,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          // borderRadius: widget.borderRadius ?? BorderRadius.zero,
          onTap: () {
            _toggleOverlay(context);
          },
          child: widget.child,
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    // print(size);
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            child: GestureDetector(
              onTap: () => _toggleOverlay(context, close: true),
              child: CompositedTransformFollower(
                link: _layerLink,
                offset: Offset(0.0, $styles.sizes.defaultAppBarSize.height),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: $styles.curves.defaultCurve,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _animationController,
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleOverlay(
    BuildContext context, {
    bool close = false,
    bool forceClose = true,
  }) async {
    if (_isOpen && forceClose == false) {
      return;
    }
    if (_isOpen || (close && forceClose)) {
      await _animationController.reverse();
      _overlayEntry?.remove();
      setState(() => _isOpen = false);
      // widget.onToggle?.call(false);
    } else {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context, rootOverlay: false).insert(_overlayEntry!);
      setState(() => _isOpen = true);
      // _overlayEntry!.maintainState = true;
      // _overlayEntry!.opaque = true;

      await _animationController.forward();
      // widget.onToggle?.call(true);
    }
  }
}
