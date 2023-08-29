import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/views/shared/impulse_ink_well.dart';

class ChangeSettingsTile extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final String subTitle;
  const ChangeSettingsTile({
    super.key,
    required this.title,
    required this.subTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      // color: Colors.black,
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          height: 70,
          width: constraints.maxWidth,
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
                  SizedBox(
                    width: constraints.maxWidth - 90,
                    child: Text(
                      subTitle,
                      maxLines: 5,
                      style: $styles.text.bodySmall.copyWith(
                        height: 1.2,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(.5),
                      ),
                    ),
                  ),
                ],
              ),
              ImpulseInkWell(
                onTap: onTap,
                child: Container(
                  height: 30,
                  width: 80.scale,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    borderRadius: BorderRadius.circular($styles.corners.sm),
                  ),
                  child: Center(
                    child: Text(
                      "Change",
                      style: $styles.text.bodySmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
