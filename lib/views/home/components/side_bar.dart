import 'dart:developer';

import 'package:flutter/cupertino.dart' hide ConnectionState;
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/models/models.dart' as m;
import 'package:impulse/controllers/controllers.dart';
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
  Map<String, (IconData, IconData)> get bars => {
        if (isAndroid)
          "Home": (ImpulseIcons.bx_home_alt_2, ImpulseIcons.bxs_home_alt_2),
        "Files": (ImpulseIcons.bx_folder, ImpulseIcons.bxs_folder),
        "Settings": (ImpulseIcons.bx_cog, ImpulseIcons.bxs_cog),
      };

  void _doNav() {
    if (GoRouter.of(context)
        .location
        .contains(ref.read(connectUserStateProvider)!.user.name)) {
      return;
    }

    ///if we are in our file manager already, we want to pop all nested routes and start browsing connected user's files
    ///on a new route. that way it starts anew navigation/pages chain.
    ///
    ///starting a new navigation/pages chain is important because that means we wont be able to jump back and forth
    ///connected user's files by just pushing and popping pages. this does not makes sense since both file managers are not
    ///connected to each other.
    ///
    ///
    while (GoRouter.of(context).location.contains("files") &&
        GoRouter.of(context).location != ImpulseRouter.routes.folder) {
      ref
          .read(pathController.notifier)
          .removeUntil(m.Path(location: ImpulseRouter.routes.folder));
      context.pop();
    }
    context.pushNamed(
      "NetworkfilesPath",
      pathParameters: {
        "path": "root",
        "username": ref.read(connectUserStateProvider)!.user.name,
      },
      // extra: widget.item.fileSystemEntity.path,
    );
  }

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
                            setState(() {});
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            color: Colors.transparent,
                            // padding: 5.scale.insetsLeft,
                            child: Row(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 1.5,
                                  height: (80 / 100) * 50,
                                  color:
                                      i == widget.navigationShell.currentIndex
                                          ? $styles.colors.secondaryColor
                                          : null,
                                ),
                                SizedBox(width: $styles.insets.sm),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        i == widget.navigationShell.currentIndex
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
                  Consumer(
                    builder: (context, ref, child) {
                      if (ref.watch(connectionStateProvider).isConnected) {
                        return InkWell(
                          onTap: () async {
                            ///since the only tab for file manager naviagtion if the file manager tab, we want to check
                            ///if we are already on the tab, (for android its 0 and for other platforms its 1). if we are we
                            ///do the navigation and if we are not, we move to the file manager tab before doing the navigation,
                            ///
                            ///
                            ///if we dont do this, it pushes a new page on top of whichever tab we have at that moment
                            if (widget.navigationShell.currentIndex !=
                                (isAndroid ? 1 : 0)) {
                              widget.navigationShell
                                  .goBranch((isAndroid ? 1 : 0));
                              await Future.delayed(
                                      const Duration(milliseconds: 50))
                                  .then((value) => _doNav());
                            } else {
                              _doNav();
                            }
                          },
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            color: Colors.transparent,
                            child: Center(
                              child: Row(
                                children: [
                                  SizedBox(width: $styles.insets.sm),
                                  const FilePlaceHolder(
                                      name: "", isFolder: true, folderSize: 30),
                                  SizedBox(width: $styles.insets.sm),
                                  Text(
                                    ref
                                        .read(connectUserStateProvider)!
                                        .user
                                        .name,
                                    style: $styles.text.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
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
            child: const SideBarProgressTile(),
          ),
        ],
      ),
    );
  }

  void onChanged(int index) {
    if (index == widget.navigationShell.currentIndex) return;
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

class _TransferDialogState extends ConsumerState<TransferDialog> {
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
