import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';

class PathBuilder extends StatelessWidget {
  const PathBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - ($styles.insets.md * 2),
      child: SingleChildScrollView(
        // controller: _controller,
        scrollDirection: Axis.horizontal,
        // physics: const NeverScrollableScrollPhysics(),
        // reverse: true,
        child: Consumer(builder: (context, ref, child) {
          final paths = ref.watch(pathController);
          final pathsController = ref.watch(pathController.notifier);
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (widget.path != null)
              for (final path in paths)
                Row(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if (GoRouter.of(context).location == path.location)
                            return;
                          pathsController.removeUntil(path);
                          while (
                              GoRouter.of(context).location != path.location) {
                            context.pop();
                          }
                        },
                        child: Padding(
                          padding:
                              ($styles.insets.md, $styles.insets.md).insets,
                          child: Text(
                            path.name,
                            style: $styles.text.body,
                          ),
                        ),
                      ),
                    ),
                    path.path != (paths.last.path)
                        ? const Icon(
                            Icons.chevron_right_sharp,
                            weight: 100,
                          )
                        // Text(">", style: $styles.text.body)
                        : const SizedBox(),
                  ],
                ),
            ],
          );
        }),
      ),
    );
  }
}
