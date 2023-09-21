// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/views/shared/custom_dialog.dart';

class ContinueDownloadDialog extends ConsumerWidget {
  const ContinueDownloadDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomDialog(
      label: "Do you want continue download ?",
      leftAction: () async {
        Navigator.pop(context);
      },
      rightAction: () async {
        try {
          final connectedUser = ref.read(connectUserStateProvider)!;
          final receiverController = ref.read(receiverProvider);
          await receiverController
              .continuePreviousDownloads(destination: connectedUser)
              .then(
            (value) {
              final connectedUserSessions =
                  ref.read(connectedUserPreviousSessionStateProvider)!;
              final prevItemsIds =
                  connectedUserSessions.prevSession.previousSessionReceivable;
              for (final prevItem in prevItemsIds) {
                log("$prevItem ::::::::::::::::: Receivable");

                ref
                    .read(receivableListItems.notifier)
                    .continueDownloads(prevItem);
              }
              Navigator.pop(context);
            },
          );
        } catch (e) {
          Navigator.pop(context);
        }
      },
    );
  }
}
