import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/views/shared/impulse_ink_well.dart';

class AboutTile extends StatelessWidget {
  final String imageUrl;
  final String imageUrlDark;
  final String tag;
  final bool isSvg;
  final VoidCallback? onTap;
  const AboutTile({
    super.key,
    required this.imageUrl,
    required this.tag,
    this.onTap,
    this.isSvg = false,
    required this.imageUrlDark,
  });

  String _imageUrl(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return imageUrlDark;
    } else {
      return imageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ImpulseInkWell(
      onTap: () => onTap?.call(),
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular($styles.corners.md),
          border: Border.all(
            color: Theme.of(context).textTheme.bodySmall!.color!,
          ),
        ),
        padding: ($styles.insets.md, $styles.insets.md).insetsLeftRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isSvg
                ? SvgPicture.asset(
                    _imageUrl(context),
                    height: 25,
                    width: 25,
                  )
                : Image.asset(
                    _imageUrl(context),
                    height: 25,
                    width: 25,
                  ),
            const SizedBox(width: 20),
            Text(
              tag,
              style: $styles.text.body,
            ),
          ],
        ),
      ),
    );
  }
}
