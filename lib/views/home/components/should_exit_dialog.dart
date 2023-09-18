// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/views/shared/custom_dialog.dart';

class ShouldExitDialog extends ConsumerWidget {
  const ShouldExitDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomDialog(
      label: "Are you sure you want to cancel this connection and exit ?",
      leftAction: () async {
        Navigator.pop<bool>(context, false);
      },
      rightAction: () async {
        try {
          await disconnect(GenericProviderRef(ref))
              .then((value) => Navigator.pop<bool>(context, true));
        } catch (e) {
          Navigator.pop<bool>(context, true);
        }
      },
    );
  }
}
