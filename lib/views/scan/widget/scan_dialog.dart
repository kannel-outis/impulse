// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';

class ScanDialog extends ConsumerStatefulWidget {
  final String ip;
  final int port;
  const ScanDialog({
    super.key,
    required this.ip,
    required this.port,
  });

  @override
  ConsumerState<ScanDialog> createState() => _ScanDialogState();
}

class _ScanDialogState extends ConsumerState<ScanDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(receiverProvider).establishConnection(
            hostIp: widget.ip,
            port: widget.port,
            listReset: true,
          );

      ref.read(connectionStateProvider.notifier).addListener(_listener);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _listener(state) {
    ref.read(homeProvider).shouldShowTopStack = true;
    if (state == ConnectionState.connected) {
      while (GoRouter.of(context).location != ImpulseRouter.routes.home) {
        context.pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 400,
        width: double.infinity,
        color: $styles.colors.accentColor1,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Consumer(
          builder: (context, ref, child) {
            final receiverController = ref.watch(receiverProvider);
            if (receiverController.availableHostServers.isEmpty) {
              return Center(
                child: Text(
                  "Loading...",
                  style: $styles.text.body,
                ),
              );
            }
            final serverInfo = receiverController.availableHostServers.single;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    image: DecorationImage(
                      image: NetworkImage(
                        serverInfo.user.displayImage,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: $styles.insets.xs),
                Text(
                  serverInfo.user.name,
                  style: $styles.text.h3,
                ),
                if (serverInfo.ipAddress != null && serverInfo.port != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        serverInfo.ipAddress!,
                        style: $styles.text.body,
                      ),
                      SizedBox(width: $styles.insets.xs),
                      Text(
                        serverInfo.port.toString(),
                        style: $styles.text.body,
                      ),
                    ],
                  ),
                SizedBox(height: $styles.insets.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ScanDialogButton(
                      color: Colors.red,
                      label: "Cancel",
                      onTap: () {
                        context.pop(false);
                      },
                    ),
                    ScanDialogButton(
                      color: $styles.colors.secondaryColor,
                      label: "Connect",
                      onTap: () async {
                        final provider = ref.read(receiverProvider);

                        provider.selectHost(serverInfo);

                        final result =
                            await provider.createServerAndNotifyHost();
                        if (result == null) {
                          ref
                              .read(userTypeProvider.notifier)
                              .setUserState(UserType.client);
                          // ref.read(homeProvider).shouldShowTopStack = true;
                        }
                      },
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class ScanDialogButton extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback? onTap;
  const ScanDialogButton({
    super.key,
    required this.color,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 180,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular($styles.corners.md),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: $styles.text.body.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
