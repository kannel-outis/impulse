import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';

import 'impulse_ink_well.dart';

class ContinueDownloadDialog extends ConsumerWidget {
  const ContinueDownloadDialog({
    super.key,
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
              "Do you want continue download ?",
              style: $styles.text.body,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _optionButton(
                  ref,
                  "No",
                  context,
                  () async {
                    Navigator.pop(context);
                  },
                ),
                _optionButton(
                  ref,
                  "Yes",
                  context,
                  () async {
                    final connectedUser = ref.read(connectUserStateProvider)!;
                    final receiverController = ref.read(receiverProvider);
                    await receiverController
                        .continuePreviousDownloads(destination: connectedUser)
                        .then(
                      (value) {
                        final connectedUserSessions = ref
                            .read(connectedUserPreviousSessionStateProvider)!;
                        final prevItemsIds = connectedUserSessions
                            .prevSession.previousSessionReceivable;
                        for (final prevItem in prevItemsIds) {
                          log("$prevItem ::::::::::::::::: Receivable");

                          ref
                              .read(receivableListItems.notifier)
                              .continueDownloads(prevItem);
                        }
                        Navigator.pop(context);
                      },
                    );
                  },
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
          border: Border.all(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          borderRadius: BorderRadius.circular(
            $styles.corners.sm,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: $styles.text.bodySmallBold,
        ),
      ),
    );
  }
}
