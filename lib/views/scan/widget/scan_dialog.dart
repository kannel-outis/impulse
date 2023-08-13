import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';

class ScanDialog extends ConsumerStatefulWidget {
  final String? parentLocation;
  final String ip;
  final int port;
  const ScanDialog({
    super.key,
    this.parentLocation,
    required this.ip,
    required this.port,
  });

  @override
  ConsumerState<ScanDialog> createState() => _ScanDialogState();
}

class _ScanDialogState extends ConsumerState<ScanDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 400,
        width: double.infinity,
        color: $styles.colors.accentColor1,
        child: GestureDetector(
          onTap: () {
            // context.pop();
          },
        ),
      ),
    );
  }
}
