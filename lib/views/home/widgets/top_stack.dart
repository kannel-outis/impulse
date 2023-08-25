import 'package:flutter/cupertino.dart' hide ConnectionState;
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/impulse_scaffold.dart';
import 'package:impulse/views/home/widgets/spinner.dart';
import 'package:impulse/views/shared/padded_body.dart';

class TopStack extends ConsumerStatefulWidget {
  const TopStack({
    super.key,
  });

  @override
  ConsumerState<TopStack> createState() => _TopStackState();
}

class _TopStackState extends ConsumerState<TopStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: $styles.times.med,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    final isConnected = connectionState == ConnectionState.connected;
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: $styles.curves.defaultCurve,
        ),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              useRootNavigator: true,
              builder: (context) {
                return ConnectionInfo();
              },
            );
          },
          // child: Spinner(
          //   size: 35,
          //   spin: isConnected,
          //   color: isConnected ? Colors.green : $styles.colors.iconColor3,
          //   child: AnimatedContainer(
          //     duration: $styles.times.fast,
          //     // height: 25,
          //     // width: 25,
          //     decoration: BoxDecoration(
          //       // color: isConnected ? Colors.green : $styles.colors.iconColor3,
          //       borderRadius: BorderRadius.circular(100),
          //     ),
          //     child: SizedBox(
          //       child: SvgPicture.asset(
          //         AssetsImage.wifi,
          //         height: 20,
          //         width: 20,
          //         theme: SvgTheme(
          //           currentColor:
          //               isConnected ? Colors.green : $styles.colors.iconColor3,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          child: AnimatedContainer(
            duration: $styles.times.fast,
            // height: 25,
            // width: 25,
            decoration: BoxDecoration(
              // color: isConnected ? Colors.green : $styles.colors.iconColor3,
              borderRadius: BorderRadius.circular(100),
            ),
            child: SizedBox(
              child: SvgPicture.asset(
                AssetsImage.wifi,
                height: 20,
                width: 20,
                theme: SvgTheme(
                  currentColor: isConnected
                      ? Colors.green
                      : Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConnectionInfo extends ConsumerStatefulWidget {
  const ConnectionInfo({
    super.key,
  });

  @override
  ConsumerState<ConnectionInfo> createState() => _ConnectionInfoState();
}

class _ConnectionInfoState extends ConsumerState<ConnectionInfo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: $styles.times.med,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: $styles.curves.defaultCurve,
        ),
      ),
      child: Dialog(
        child: Container(
          height: 500,
          width: 400,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Consumer(builder: (context, ref, child) {
                  final connectionState = ref.watch(connectionStateProvider);
                  final isConnected =
                      connectionState == ConnectionState.connected;
                  return SvgPicture.asset(
                    AssetsImage.wifi,
                    height: 200,
                    width: 200,
                    theme: SvgTheme(
                      currentColor: isConnected
                          ? Colors.green
                          : Theme.of(context).colorScheme.tertiary,
                    ),
                  );
                }),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 200,
                  width: 200,
                  color:
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(.8),
                ),
              ),
              ImpulseScaffold(
                showOverlay: false,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: Text(
                      "CONNECTION INFORMATION",
                      style: $styles.text.h3,
                    ),
                    centerTitle: true,
                  ),
                  body: PaddedBody(
                    child: Consumer(
                      builder: (context, ref, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Column(
                                children: [
                                  ConnectionInfoTile(
                                    hint: "role",
                                    label: ref.watch(userTypeProvider).name,
                                  ),
                                  ConnectionInfoTile(
                                    hint: "ip",
                                    label: ref
                                        .watch(serverControllerProvider)
                                        .ipAddress
                                        .toString(),
                                  ),
                                  ConnectionInfoTile(
                                    hint: "port",
                                    label: ref
                                        .watch(serverControllerProvider)
                                        .port
                                        .toString(),
                                  ),
                                  ConnectionInfoTile(
                                    hint: "connection",
                                    label: ref
                                        .watch(connectionStateProvider)
                                        .label,
                                  ),
                                  ConnectionInfoTile(
                                    hint: ref.read(userTypeProvider) ==
                                            UserType.client
                                        ? "host ip"
                                        : "client ip",
                                    label: ref
                                            .watch(connectUserStateProvider)
                                            ?.ipAddress
                                            ?.toString() ??
                                        "null",
                                  ),
                                  ConnectionInfoTile(
                                    hint: ref.read(userTypeProvider) ==
                                            UserType.client
                                        ? "host port"
                                        : "client port",
                                    label: ref
                                            .watch(connectUserStateProvider)
                                            ?.port
                                            ?.toString() ??
                                        "null",
                                  ),
                                  ConnectionInfoTile(
                                    hint: ref.read(userTypeProvider) ==
                                            UserType.client
                                        ? "host id"
                                        : "client id",
                                    label: ref
                                            .watch(connectUserStateProvider)
                                            ?.user
                                            .id ??
                                        "",
                                  ),
                                  ConnectionInfoTile(
                                    hint: ref.read(userTypeProvider) ==
                                            UserType.client
                                        ? "host name"
                                        : "client name",
                                    label: ref
                                            .watch(connectUserStateProvider)
                                            ?.user
                                            .name ??
                                        "",
                                  ),
                                  ConnectionInfoTile(
                                    hint: ref.read(userTypeProvider) ==
                                            UserType.client
                                        ? "host device"
                                        : "client device",
                                    label:
                                        "${ref.watch(connectUserStateProvider)?.user.deviceName} ${ref.watch(connectUserStateProvider)?.user.deviceOsVersion}",
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.only(bottom: $styles.insets.sm),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      disconnect(GenericProviderRef(ref));
                                    },
                                    child: const Center(
                                      child: Text("Disconnect"),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectionInfoTile extends StatelessWidget {
  final String hint;
  final String label;
  const ConnectionInfoTile({
    super.key,
    required this.hint,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$hint  - ".toUpperCase(), style: $styles.text.body),
        SizedBox(width: $styles.insets.sm),
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: $styles.text.body,
            maxLines: 2,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
