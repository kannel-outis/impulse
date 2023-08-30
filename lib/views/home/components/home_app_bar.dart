import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';

import '../widgets/top_stack.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const HomeAppBar({super.key, required this.title});

  ImageProvider _imageProvider(String image) {
    if (image.isAsset) {
      return AssetImage(image);
    } else {
      return FileImage(image.toFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return LayoutBuilder(builder: (context, constrains) {
        return Container(
          height: $styles.sizes.defaultAppBarSize.height,
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: constrains.maxWidth.toInt() < $styles.tabletLg
                ? $styles.shadows.boxShadowSmall
                : null,
          ),
          child: Padding(
            padding: ($styles.insets.md, $styles.insets.md).insetsLeftRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // SizedBox(
                //   width: 30 * $styles.scale,
                // ),
                Text(
                  title,
                  style: $styles.text.h3.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  child: Row(
                    children: [
                      if (ref.watch(homeProvider).shouldShowTopStack)
                        const TopStack(),
                      // SizedBox(width: $styles.insets.md * .5),

                      SizedBox(width: $styles.insets.md),

                      Consumer(
                        builder: (context, ref, child) {
                          final image = ref.watch(profileImageProvider);
                          return Container(
                            height: 40.scale,
                            width: 40.scale,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceTint,
                              borderRadius:
                                  BorderRadius.circular($styles.corners.xxlg),
                              image: DecorationImage(
                                image: _imageProvider(
                                  image ??
                                      Configurations
                                          .instance.user!.displayImage,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    });
  }

  @override
  Size get preferredSize => $styles.sizes.defaultAppBarSize;
}
