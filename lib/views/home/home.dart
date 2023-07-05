import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/views/files/file_manager.dart';
import 'package:impulse/views/home/widgets/app_item.dart';
import 'package:impulse/views/settings/settings_screen.dart';
import 'package:impulse/views/shared/custom_overlay_not.dart';
import 'package:impulse/views/shared/custom_speed_dial.dart';
import 'package:impulse/views/shared/padded_body.dart';

import 'components/bottom_nav_bar.dart';
import 'widgets/speed_child_item.dart';
import 'widgets/top_stack.dart';

part 'images.dart';
part 'videos.dart';
part 'apps.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController;
  late final _key = GlobalKey();

  int index = 0;

  bool tabBarTapped = false;
  bool isOverlayOpen = false;
  bool waitForOverlayReverseAnimation = true;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);
    _pageController = PageController();
  }

  List<Widget> get tabs => <Widget>[
        Text("Apps", style: bodyStyle),
        Text("Images", style: bodyStyle),
        Text("Videos", style: bodyStyle),
      ];

  Offset get getPositionOffset {
    final renderBox = _key.currentContext!.findRenderObject() as RenderBox?;
    final size = renderBox!.size;

    final offset = renderBox.localToGlobal(Offset.zero);
    print(offset.dy);
    return offset;
  }

  void closeOverlay() {
    isOverlayOpen = false;
    setState(() {});
    waitforOverlayReverseAnimation(false);
  }

  void waitforOverlayReverseAnimation(bool wait) {
    waitForOverlayReverseAnimation = wait;
  }

  @override
  Widget build(BuildContext context) {
    final homeController = ref.watch(homeProvider);
    final hostController = ref.watch(hostProvider);

    return SafeArea(
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
                      Container(
                        height: 40.scale,
                        width: 40.scale,
                        decoration: BoxDecoration(
                          color: $styles.colors.fontColor2,
                          borderRadius:
                              BorderRadius.circular($styles.corners.xxlg),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: PageView(
              controller: _pageController,
              // onPageChanged: (page) {
              //   index = page;
              //   setState(() {});
              // },
              physics: const NeverScrollableScrollPhysics(),
              children: [
                if (isAndroid) Home(tabController: _tabController, tabs: tabs),
                const FileManagerScreen(),
                const SettingScreen(),
              ],
            ),
            floatingActionButton: CustomSpeedDial(
              open: isOverlayOpen,
              disable: hostController.host.isServerRunning,
              toolTipMessage: homeController.isWaitingForReceiver
                  ? "Waiting for connection"
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
                child: const Icon(
                  ImpulseIcons.transfer5,
                  size: 30,
                ),
              ),
              // childSpacing: .4,
              children: [
                SpeedChild(
                  onTap: () {
                    closeOverlay();
                    hostController.createServer().then((value) {
                      homeController.isWaitingForReceiver = true;
                      print(hostController.myServer);
                    });
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
            ),
            bottomNavigationBar: MyBottomNavBar(
              index: index,
              onChanged: (index) {
                this.index = index;
                setState(() {});
                _pageController.animateToPage(
                  index,
                  duration: $styles.times.pageTransition,
                  curve: $styles.curves.defaultCurve,
                );
              },
            ),
          ),
          if (homeController.shouldShowTopStack)
            Positioned(
              ///minus the size of the top stack
              top: getPositionOffset.dy - 30,
              width: MediaQuery.of(context).size.width,
              child: const TopStack(),
            ),
        ],
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({
    super.key,
    required TabController tabController,
    required this.tabs,
  }) : _tabController = tabController;

  final TabController _tabController;
  final List<Widget> tabs;

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
