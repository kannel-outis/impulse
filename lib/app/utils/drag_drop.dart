// import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:mime/mime.dart';

class DragNDrop extends StatefulWidget {
  final Widget child;
  const DragNDrop({super.key, required this.child});

  @override
  State<DragNDrop> createState() => _DragNDropState();
}

class _DragNDropState extends State<DragNDrop> {
  bool _hasEnteredRegion = false;

  Color _brightnessColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Colors.white.withOpacity(.2);
    } else {
      return Colors.black.withOpacity(.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(child: LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            widget.child,
            IgnorePointer(
              child: Container(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                color: _hasEnteredRegion
                    ? _brightnessColor(context)
                    : Colors.transparent,
              ),
            )
          ],
        );
      },
    ), builder: (context, ref, child) {
      // return DropTarget(
      //   enable:
      //       !GoRouter.of(context).location.contains(ImpulseRouter.routes.home),
      //   onDragDone: (details) async {
      //     for (var item in details.files) {
      //       if (lookupMimeType(item.path) != null) {
      //         ref
      //             .read(selectedItemsProvider.notifier)
      //             .addSelected(path: item.path);
      //       }
      //     }
      //     if (ref.read(connectionStateProvider).isConnected) {
      //       final genericRef = GenericProviderRef<WidgetRef>(ref);

      //       await share(genericRef);
      //       return;
      //     }
      //     showModel(true, context);
      //   },
      //   onDragEntered: (_) {
      //     _hasEnteredRegion = true;
      //     setState(() {});
      //   },
      //   onDragExited: (_) {
      //     _hasEnteredRegion = false;
      //     setState(() {});
      //   },
      //   child: child!,
      // );
      return child!;
    });
  }
}
