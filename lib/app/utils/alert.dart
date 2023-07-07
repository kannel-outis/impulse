import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/controllers/controllers.dart';

import 'globals.dart';

class AlertOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const AlertOverlay({super.key, required this.child});

  // ignore: library_private_types_in_public_api
  static _AlertOverlayState of(BuildContext context) {
    return context.findRootAncestorStateOfType<_AlertOverlayState>()!;
  }

  @override
  ConsumerState<AlertOverlay> createState() => _AlertOverlayState();
}

class _AlertOverlayState extends ConsumerState<AlertOverlay>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late final AnimationController _animationController;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: $styles.times.med,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.watch(alertStateNotifier.notifier).addListener((state) {
        print(state);
        if (state == true) {
          toggleOverlay();
        } else {
          toggleOverlay(close: true);
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.child,
    );
  }

  OverlayEntry _createOverlayEntry() {
    // print(size);
    return OverlayEntry(
      builder: (context) {
        return _OverlayChild(
          toggle: () {
            toggleOverlay(close: true);
          },
          layerLink: _layerLink,
          animationController: _animationController,
        );
      },
    );
  }

  Future<void> toggleOverlay({
    bool close = false,
    bool forceClose = true,
  }) async {
    if (_isOpen == false && close == true) return;
    if (_isOpen && forceClose == false) {
      return;
    }
    if (_isOpen || (close && forceClose)) {
      await _animationController.reverse();
      _overlayEntry?.remove();
      setState(() => _isOpen = false);
      // widget.onToggle?.call(false);
    } else {
      _overlayEntry = _createOverlayEntry();

      Overlay.of(context).insert(_overlayEntry!);
      setState(() => _isOpen = true);
      // _overlayEntry!.maintainState = true;
      // _overlayEntry!.opaque = true;

      await _animationController.forward();
      // widget.onToggle?.call(true);
    }
  }
}

class _OverlayChild extends StatelessWidget {
  final Function() toggle;
  const _OverlayChild({
    Key? key,
    required this.toggle,
    required LayerLink layerLink,
    required AnimationController animationController,
  })  : _layerLink = layerLink,
        _animationController = animationController,
        super(key: key);

  final LayerLink _layerLink;
  final AnimationController _animationController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        GestureDetector(
          onTap: () => toggle(),
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(0.0, -(10).toDouble()),
            child: SlideTransition(
              position: Tween<Offset>(
                end: const Offset(0, 1),
                begin: Offset.zero,
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
                  width: 500,
                  constraints: BoxConstraints(
                      maxWidth: $styles.constraints.modalConstraints.maxWidth),
                  alignment: Alignment.center,
                  // decoration: BoxDecoration(),
                  color: $styles.colors.iconColor2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
