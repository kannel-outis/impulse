import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/views/home/widgets/app_item.dart';
import 'package:impulse/views/shared/custom_speed_dial.dart';
import 'package:impulse/views/shared/padded_body.dart';
import 'package:impulse/views/shared/selectable_item_widget.dart';
import 'package:impulse/views/transfer/transfer_page.dart';
import 'package:impulse/views/transfer/widgets/transfer_list_tile.dart';
import 'package:impulse_utils/impulse_utils.dart';

import 'components/bottom_nav_bar.dart';
import 'components/home_app_bar.dart';
import 'widgets/path_nav_builder.dart';
import 'widgets/speed_child_item.dart';

part 'components/images.dart';
part 'videos.dart';
part 'components/apps.dart';

class HomePage extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const HomePage({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  int index = 0;

  bool tabBarTapped = false;
  bool isOverlayOpen = false;
  bool waitForOverlayReverseAnimation = true;
  @override
  void initState() {
    super.initState();
  }

  void closeOverlay() {
    isOverlayOpen = false;
    setState(() {});
    waitforOverlayReverseAnimation(false);
  }

  void waitforOverlayReverseAnimation(bool wait) {
    /// for some case we want to not wait for the overlay reverse animation
    /// e.g when we wan to show a modal or a dialog because, the overlay stays on top on the dialog
    /// and makes it weird. so instead of waiting we just snap it out unnoticable.
    waitForOverlayReverseAnimation = wait;
  }

  bool _isPhone(double size) {
    return size > $styles.tabletLg;
  }

  Map<String, (IconData, IconData)> get bars => {
        "Files": (ImpulseIcons.bx_folder, ImpulseIcons.bxs_folder),
        "Settings": (ImpulseIcons.bx_cog, ImpulseIcons.bxs_cog),
      };

  Widget _sideBar(double size) {
    if (_isPhone(size)) {
      return Container(
        width: (MediaQuery.of(context).size.width / 100) * 20,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 50,
                    width: double.infinity,
                    margin: $styles.insets.xs.insetsBottom,
                  ),
                  for (var i = 0; i < bars.length; i++)
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
                        padding: $styles.insets.md.insetsLeft,
                        margin: $styles.insets.xs.insetsBottom,
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
                ],
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final connectionState = ref.watch(connectionStateProvider);
                if (connectionState == ConnectionState.connected) {
                  return Consumer(
                    builder: (context, ref, child) {
                      final shareable = ref.watch(shareableItemsProvider);
                      final downloadManager =
                          ref.watch(downloadManagerProvider);

                      ref.watch(receivableListItems);
                      if (downloadManager.$2 != null) {
                        return TransferListTile(
                          item: downloadManager.$2!,
                          mini: true,
                          mBps:
                              ImpulseFileSize(downloadManager.$1).sizeToString,
                          height: 70,
                          width: (MediaQuery.of(context).size.width / 100) * 20,
                        );
                      }

                      if (shareable.isEmpty) {
                        return Container(
                          height: 70,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.white,
                                width: .5,
                              ),
                              // bottom: BorderSide(
                              //   color: Colors.white,
                              //   width: 1,
                              // ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "No Shared Item yet",
                              style: $styles.text.body,
                            ),
                          ),
                        );
                      }
                      final inProgressItemsWidget = shareable
                          .where((element) => element.state.isInProgress)
                          .toList()
                          .map(
                            (e) => TransferListTile(
                              height: 70,
                              mini: true,
                              item: e,
                              width: (MediaQuery.of(context).size.width / 100) *
                                  20,
                            ),
                          )
                          .toList();
                      return inProgressItemsWidget.isEmpty
                          ? TransferListTile(
                              item: shareable.last,
                              mini: true,
                              height: 70,
                              width: (MediaQuery.of(context).size.width / 100) *
                                  20,
                            )
                          : inProgressItemsWidget.first;
                    },
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final miniPlayerControllerP = ref.read(miniPlayerController);
        if (miniPlayerControllerP.isClosed == false) {
          miniPlayerControllerP.closeMiniPlayer();
          return false;
        } else {
          return true;
        }
      },
      child: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return Stack(
            children: [
              Scaffold(
                appBar: const HomeAppBar(),
                body: Flex(
                  direction: _isPhone(constraints.maxWidth)
                      ? Axis.horizontal
                      : Axis.vertical,
                  children: [
                    _sideBar(constraints.maxWidth),
                    VerticalDivider(
                      thickness: .5,
                      color: $styles.colors.fontColor1.withOpacity(.2),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          if (widget.navigationShell.currentIndex ==
                              (isAndroid ? 1 : 0))
                            const PathBuilder(),
                          Expanded(child: widget.navigationShell),
                        ],
                      ),
                    ),
                  ],
                ),
                floatingActionButton: Consumer(builder: (context, ref, child) {
                  final homeController = ref.watch(homeProvider);
                  final hostController = ref.watch(senderProvider);
                  final connectionState = ref.watch(connectionStateProvider);
                  final selectedItems = ref.watch(selectedItemsProvider);

                  if (connectionState == ConnectionState.notConnected &&
                      selectedItems.isNotEmpty) {
                    return GestureDetector(
                      onTap: () {
                        showModel(true, context);
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Theme.of(context).colorScheme.primary,
                        ),

                        /// This particular icon is not aligned properly
                        /// it had to be manually done
                        alignment: const Alignment(0.0, .2),
                        child: SvgPicture.asset(
                          AssetsImage.send,
                          theme: SvgTheme(
                            currentColor: Colors.white,
                            fontSize: 50.scale,
                          ),
                        ),
                      ),
                    );
                  } else {
                    if (connectionState == ConnectionState.connected) {
                      return Container();
                    } else {
                      return CustomSpeedDial(
                        open: isOverlayOpen,
                        disable: hostController.host.isServerRunning ||
                            connectionState == ConnectionState.connected,
                        disabledFunction: () {
                          showModel(true, context);
                        },
                        toolTipMessage: homeController.isWaitingForReceiver
                            ? connectionState == ConnectionState.connected
                                ? "Connected"
                                : "Waiting for connection"
                            : "Connect",
                        waitForReverseAnimation: waitForOverlayReverseAnimation,
                        onToggle: (isOpen) {
                          waitforOverlayReverseAnimation(true);
                          if (isOpen != isOverlayOpen) {
                            isOverlayOpen = isOpen;
                            setState(() {});
                          }
                        },
                        overlayChildrenOffset: const Offset(0.0, -10),
                        duration: $styles.times.med,
                        child: Stack(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Theme.of(context).colorScheme.primary,
                              ),

                              /// This particular icon is not aligned properly
                              /// it had to be manually done
                              alignment: const Alignment(0.0, .2),
                              child: const Icon(
                                ImpulseIcons.transfer5,
                                size: 30,
                              ),
                            ),
                            if (hostController.host.isServerRunning ||
                                connectionState == ConnectionState.connected)
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.black.withOpacity(.5),
                                ),
                              ),
                          ],
                        ),
                        // childSpacing: .4,
                        children: [
                          SpeedChild(
                            onTap: () {
                              closeOverlay();
                            },
                            icon: Icons.file_upload_rounded,
                          ),
                          SpeedChild(
                            isHost: false,
                            onTap: () {
                              closeOverlay();
                            },
                            icon: Icons.file_download_rounded,
                          ),
                          if (isAndroid)
                            SpeedChild(
                              isHost: false,
                              disableDefaultFunc: true,
                              onTap: () {
                                closeOverlay();
                                context.push(ImpulseRouter.routes.scanPage);
                              },
                              icon: Icons.ac_unit,
                            ),
                        ].reversed.toList(),
                      );
                    }
                  }
                }),
                bottomNavigationBar: _isPhone(constraints.maxWidth)
                    ? null
                    : MyBottomNavBar(
                        index: widget.navigationShell.currentIndex,
                        onChanged: onChanged,
                      ),
              ),
              if (!_isPhone(constraints.maxWidth))
                Consumer(
                  builder: (context, ref, child) {
                    final connectionState = ref.watch(connectionStateProvider);
                    if (connectionState == ConnectionState.connected) {
                      return const TransferPage();
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
            ],
          );
        }),
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

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  List<Widget> get tabs => <Widget>[
        Text("Apps", style: bodyStyle),
        Text("Images", style: bodyStyle),
        Text("Videos", style: bodyStyle),
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return PaddedBody(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            labelPadding: EdgeInsets.only(
              bottom: $styles.insets.xs,
              right: $styles.insets.md,
              top: $styles.insets.sm,
            ),
            splashFactory: NoSplash.splashFactory,
            isScrollable: true,
            controller: _tabController,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            indicatorColor: $styles.colors.fontColor1,
            labelColor: $styles.colors.fontColor1,
            indicatorWeight: 1,
            tabs: tabs,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                AppsPage(),
                ImagesPage(),
                VideosPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
