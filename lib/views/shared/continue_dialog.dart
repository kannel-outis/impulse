import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/services/services.dart';

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
                  "No",
                  context,
                  () {
                    Navigator.pop(context);
                  },
                ),
                _optionButton(
                  "Yes",
                  context,
                  () async {
                    final connectedUser = ref.read(connectUserStateProvider)!;
                    await ref
                        .read(receiverProvider)
                        .continuePreviousDownloads(destination: connectedUser)
                        .then(
                      (value) {
                        final (_, previousSession) = ref
                            .read(connectedUserPreviousSessionStateProvider)!;

                        for (var prevItem in previousSession
                            .previousSessionReceivable
                            .where((element) => !element.state.isCompleted)) {
                          
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

  Widget _optionButton(String label, BuildContext context, VoidCallback onTap) {
    return ImpulseInkWell(
      onTap: onTap,
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
