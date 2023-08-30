import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/views/shared/impulse_ink_well.dart';

class SettingsTile extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final String subTitle;
  const SettingsTile({
    required this.title,
    required this.subTitle,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ImpulseInkWell(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        height: 70,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: $styles.text.bodyBold.copyWith(height: 1.2),
                ),
                Text(
                  subTitle,
                  maxLines: 5,
                  style: $styles.text.bodySmall.copyWith(
                    height: 1.2,
                    color:
                        Theme.of(context).colorScheme.tertiary.withOpacity(.5),
                  ),
                ),
              ],
            ),
            // Icon(
            //   Icons.chevron_right,
            //   size: $styles.sizes.prefixIconSize,
            //   color: Theme.of(context).colorScheme.tertiary,
            // ),
            // FittedBox(
            //   child: SvgPicture.asset(
            //     AssetsImage.tiny_chevron_right,
            //     fit: BoxFit.cover,
            //     color: Theme.of(context).colorScheme.tertiary,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
