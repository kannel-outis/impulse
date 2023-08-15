import 'package:flutter/cupertino.dart' hide ConnectionState;
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/views/transfer/widgets/full_transfer_page.dart';

import '../widgets/side_bar_trnasfer_tile.dart';

class SideBar extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const SideBar({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<SideBar> createState() => _SideBarState();
}

class _SideBarState extends ConsumerState<SideBar> {
  int index = 0;

  Map<String, (IconData, IconData)> get bars => {
        if (isAndroid)
          "Home": (ImpulseIcons.bx_home_alt_2, ImpulseIcons.bxs_home_alt_2),
        "Files": (ImpulseIcons.bx_folder, ImpulseIcons.bxs_folder),
        "Settings": (ImpulseIcons.bx_cog, ImpulseIcons.bxs_cog),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width / 100) * 20,
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: ($styles.insets.xs, $styles.insets.xs).insetsLeftRight,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        useRootNavigator: true,
                        builder: (context) {
                          return const TransferDialog();
                        },
                      );
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      color: Theme.of(context).hoverColor,
                      margin: $styles.insets.xs.insetsBottom,
                      child: Center(
                        child: Icon(
                          CupertinoIcons.add,
                          size: 20.scale,
                        ),
                      ),
                    ),
                  ),
                  for (var i = 0; i < bars.length; i++)
                    Column(
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            onChanged(i);
                            index = i;
                            setState(() {});
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            color: Colors.transparent,
                            // padding: 5.scale.insetsLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 1.5,
                                  height: (80 / 100) * 50,
                                  color: i == index
                                      ? $styles.colors.secondaryColor
                                      : null,
                                ),
                                SizedBox(width: $styles.insets.sm),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        index == i
                                            ? bars.values.toList()[i].$2
                                            : bars.values.toList()[i].$1,
                                      ),
                                      SizedBox(width: $styles.insets.sm),
                                      Text(
                                        bars.keys.toList()[i],
                                        style: $styles.text.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: $styles.insets.xs),
                      ],
                    ),
                  Padding(
                    padding: $styles.insets.sm.insets,
                    child: Divider(
                      thickness: .5,
                      color: $styles.colors.fontColor1.withOpacity(.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                useRootNavigator: true,
                builder: (context) {
                  return Dialog(
                    child: Container(
                      child: Material(
                        child: FullTransferPage(),
                      ),
                    ),
                  );
                },
              );
            },
            child: const SideBarProgressTile(),
          ),
        ],
      ),
    );
  }

  void onChanged(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

class TransferDialog extends ConsumerStatefulWidget {
  const TransferDialog({
    super.key,
  });

  @override
  ConsumerState<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends ConsumerState<TransferDialog>
    with WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    print("Changed");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: const Material(
          child: FullTransferPage(),
        ),
      ),
    );
  }
}
