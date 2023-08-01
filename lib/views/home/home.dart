import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/services/services.dart';
import 'package:impulse/views/files/file_manager.dart';
import 'package:impulse/views/home/widgets/app_item.dart';
import 'package:impulse/views/settings/settings_screen.dart';
import 'package:impulse/views/shared/custom_speed_dial.dart';
import 'package:impulse/views/shared/padded_body.dart';
import 'package:impulse/views/shared/selectable_item_widget.dart';
import 'package:impulse/views/transfer/transfer_page.dart';
import 'package:path_provider/path_provider.dart';

import 'components/bottom_nav_bar.dart';
import 'widgets/speed_child_item.dart';
import 'widgets/spinner.dart';
import 'widgets/top_stack.dart';

part 'images.dart';
part 'videos.dart';
part 'apps.dart';

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
  // late final PageController _pageController;
  late final _key = GlobalKey();

  int index = 0;

  bool tabBarTapped = false;
  bool isOverlayOpen = false;
  bool waitForOverlayReverseAnimation = true;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _share() async {
    final destination = ref.read(connectUserStateProvider);
    if (destination == null) return;
    final hostController = ref.read(senderProvider);

    final files = ref.read(selectedItemsProvider);
    for (final item in files) {
      item.homeDestination ??= (
        ref.read(serverControllerProvider).ipAddress!,
        ref.read(serverControllerProvider).port!
      );
    }
    ref.read(shareableItemsProvider.notifier).addAllItems(files);
    final shareableFiles = ref
        .read(shareableItemsProvider.notifier)
        .filteredList
        .map((e) => e.toMap())
        .toList();
    // print(files);
    print(shareableFiles.length);

    // return;

    await hostController.shareDownloadableFiles(
        shareableFiles, (destination.ipAddress!, destination.port!));
    ref.read(selectedItemsProvider.notifier).clear();
  }

  Offset get getPositionOffset {
    final renderBox = _key.currentContext!.findRenderObject() as RenderBox?;

    final offset = renderBox!.localToGlobal(Offset.zero);
    return offset;
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
        child: Stack(
          children: [
            Scaffold(
              appBar: PreferredSize(
                key: _key,
                preferredSize: $styles.sizes.defaultAppBarSize,
                child: Container(
                  height: $styles.sizes.defaultAppBarSize.height,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: $styles.shadows.boxShadowSmall,
                  ),
                  child: Padding(
                    padding:
                        ($styles.insets.md, $styles.insets.md).insetsLeftRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // SizedBox(
                        //   width: 30 * $styles.scale,
                        // ),
                        Text(
                          "Home",
                          style: $styles.text.h3.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            ///TODO: To be removed,
                            ///
                            ///
                            // log("object");
                            // return;
                            // final d =
                            //     HiveManagerImpl().getAllReceiveableItems();
                            // for (var e in d) {
                            //   log("${e.path}: ${e.fileSize}");
                            // }
                            // return;
                            await _share();
                          },
                          child: Container(
                            height: 40.scale,
                            width: 40.scale,
                            decoration: BoxDecoration(
                              color: $styles.colors.fontColor2,
                              borderRadius:
                                  BorderRadius.circular($styles.corners.xxlg),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: widget.navigationShell,
              floatingActionButton: Consumer(builder: (context, ref, child) {
                final homeController = ref.watch(homeProvider);
                final hostController = ref.watch(senderProvider);
                final connectionState = ref.watch(connectionStateProvider);
                final selectedItems = ref.watch(selectedItemsProvider);

                return connectionState == ConnectionState.notConnected &&
                        selectedItems.isNotEmpty
                    ? Container()
                    : connectionState == ConnectionState.connected
                        ? Container()
                        : CustomSpeedDial(
                            open: isOverlayOpen,
                            disable: hostController.host.isServerRunning ||
                                connectionState == ConnectionState.connected,
                            toolTipMessage: homeController.isWaitingForReceiver
                                ? connectionState == ConnectionState.connected
                                    ? "Connected"
                                    : "Waiting for connection"
                                : "Connect",
                            waitForReverseAnimation:
                                waitForOverlayReverseAnimation,
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                                    connectionState ==
                                        ConnectionState.connected)
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
                            ].reversed.toList(),
                          );
              }),
              bottomNavigationBar: MyBottomNavBar(
                index: widget.navigationShell.currentIndex,
                onChanged: onChanged,
              ),
            ),

            ///TODO: change to overlay later
            if (ref.watch(homeProvider).shouldShowTopStack)
              Positioned(

                  ///plus the size of the top stack
                  top: getPositionOffset.dy + (Platform.isAndroid ? -40 : 20),
                  right: 0,
                  // top: $styles.sizes.defaultAppBarSize.height,
                  // width: MediaQuery.of(context).size.width,
                  child: const TopStack()),
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
        ),
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
