// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';

import 'impulse_ink_well.dart';

class CustomDialog extends ConsumerWidget {
  final String label;
  final VoidCallback rightAction;
  final VoidCallback leftAction;
  const CustomDialog({
    super.key,
    required this.label,
    required this.leftAction,
    required this.rightAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Container(
        height: 130,
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        color: Theme.of(context).colorScheme.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LayoutBuilder(builder: (context, constrainst) {
              return SizedBox(
                width: constrainst.maxWidth,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: $styles.text.body,
                ),
              );
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _optionButton(
                  ref,
                  "No",
                  context,
                  color: Theme.of(context).colorScheme.primary,
                  () async => leftAction.call(),
                ),
                _optionButton(
                  ref,
                  "Yes",
                  context,
                  color: Colors.green.withOpacity(.7),
                  () async => rightAction.call(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(WidgetRef ref, String label, BuildContext context,
      Future Function() onTap,
      {Color? color}) {
    return ImpulseInkWell(
      onTap: () {
        onTap.call();
      },
      child: Container(
        height: 30,
        width: 80,
        // color: Colors.white,
        decoration: BoxDecoration(
          // border: Border.all(
          //   color: Theme.of(context).colorScheme.tertiary,
          // ),
          color: color ?? Theme.of(context).colorScheme.primary.withOpacity(.1),
          borderRadius: BorderRadius.circular(
            $styles.corners.sm,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: $styles.text.bodySmallBold.copyWith(
            // color: Theme.of(context).colorScheme.primary,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
