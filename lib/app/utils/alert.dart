import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';

class AlertOverlay extends ConsumerStatefulWidget {
  final Widget child;
  final bool showOverlay;
  const AlertOverlay({
    super.key,
    required this.child,
    this.showOverlay = true,
  });

  // ignore: library_private_types_in_public_api
  // static _AlertOverlayState of(BuildContext context) {
  //   return context.findRootAncestorStateOfType<_AlertOverlayState>()!;
  // }

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

    //TODO: use ref.listen
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    // ref.watch(alertStateNotifier.notifier).addListener((state) {
    //   if (state == true) {
    //     toggleOverlay();
    //   } else {
    //     toggleOverlay(close: true);
    //   }
    // });
    // });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectionStateProvider, (previous, next) {
      if (next.isFling) {
        toggleOverlay();
        return;
      } else if (next.isNotConnected || next.isConnected) {
        toggleOverlay(close: true);
        return;
      }
    });
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.child,
    );
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return _OverlayChild(
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
    if (widget.showOverlay == false) return;
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

class _OverlayChild extends ConsumerStatefulWidget {
  const _OverlayChild({
    Key? key,
    required LayerLink layerLink,
    required AnimationController animationController,
  })  : _layerLink = layerLink,
        _animationController = animationController,
        super(key: key);

  final LayerLink _layerLink;
  final AnimationController _animationController;

  @override
  ConsumerState<_OverlayChild> createState() => _OverlayChildState();
}

class _OverlayChildState extends ConsumerState<_OverlayChild> {
  @override
  Widget build(BuildContext context) {
    final flingServerInfo = ref.watch(connectUserStateProvider);
    final size = MediaQuery.of(context).size;
    final style = AppStyle(screenSize: size);
    return KeyedSubtree(
      key: ValueKey(style.scale),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          GestureDetector(
            child: CompositedTransformFollower(
              link: widget._layerLink,
              offset: Offset(
                  0.0,
                  (-size.height + 10 + MediaQuery.of(context).padding.top)
                      .toDouble()),
              child: SlideTransition(
                position: Tween<Offset>(
                  end: const Offset(0, 1),
                  begin: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: widget._animationController,
                    curve: style.curves.defaultCurve,
                  ),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 500),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor
                                .withOpacity(.7),
                            // color: Color(0xff010b13),
                            boxShadow: style.shadows.boxShadowSmall,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "${flingServerInfo?.user.name} is Asking to connect to you,",
                                    style: style.text.h4,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "do you wish to proceed?",
                                    style: style.text.h4,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ButtonChild(
                                    style: style,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    label: "Decline",
                                    callback: () {
                                      ref
                                          .read(alertStateNotifier.notifier)
                                          .alertResult(false);
                                    },
                                  ),
                                  ButtonChild(
                                    style: style,
                                    color: Colors.green.withOpacity(.5),
                                    label: "Accept",
                                    callback: () {
                                      ref
                                          .read(alertStateNotifier.notifier)
                                          .alertResult(true);

                                      // ref
                                      //     .read(senderProvider)
                                      //     .handleAlertResponse(true);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
}

class ButtonChild extends StatelessWidget {
  const ButtonChild({
    super.key,
    required this.style,
    required this.color,
    required this.label,
    required this.callback,
  });
  final String label;
  final AppStyle style;
  final Color color;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(style.corners.md),
      onTap: callback,
      child: Container(
        height: 40,
        width: 140,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(style.corners.sm),
        ),
        child: Center(
          child: Text(
            label,
            style: style.text.h4.copyWith(
              color: $styles.colors.themeLight.scaffoldBackgroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
