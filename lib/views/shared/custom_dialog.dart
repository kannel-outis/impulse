// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';

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
            Text(
              label,
              style: $styles.text.body,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _optionButton(
                  ref,
                  "No",
                  context,
                  () async => leftAction.call(),
                ),
                _optionButton(
                  ref,
                  "Yes",
                  context,
                  () async => rightAction.call(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(
    WidgetRef ref,
    String label,
    BuildContext context,
    Future Function() onTap,
  ) {
    return ImpulseInkWell(
      onTap: () {
        onTap.call().then((value) {
          ///Because at this point we do not longer need the previous the previous session info anymore
          ///so we might as well just set it and save.
          // ref.read(connectedUserPreviousSessionStateProvider)!.$2
          //   ..previousSessionId = ref.read(currentSessionStateProvider)!.id
          //   ..previousSessionReceivable =
          //       ref.read(receivableListItems).map((e) => e.id).toList()
          //   ..previousSessionShareable =
          //       ref.read(shareableItemsProvider).map((e) => e.id).toList()
          //   ..save();
          // ref
          //     .read(connectedUserPreviousSessionStateProvider.notifier)
          //     .hasSetNewPrev();
        });
      },
      child: Container(
        height: 30,
        width: 80,
        // color: Colors.white,
        decoration: BoxDecoration(
          // border: Border.all(
          //   color: Theme.of(context).colorScheme.tertiary,
          // ),
          color: Theme.of(context).colorScheme.primary.withOpacity(.1),
          borderRadius: BorderRadius.circular(
            $styles.corners.sm,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: $styles.text.bodySmallBold.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
