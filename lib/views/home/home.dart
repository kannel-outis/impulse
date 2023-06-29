import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/views/files/file_manager.dart';
import 'package:impulse/views/home/widgets/app_item.dart';
import 'package:impulse/views/settings/settings_screen.dart';
import 'package:impulse/views/shared/custom_speed_dial.dart';
import 'package:impulse/views/shared/padded_body.dart';

import 'components/bottom_nav_bar.dart';
import 'widgets/speed_child_item.dart';

part 'images.dart';
part 'videos.dart';
part 'apps.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController;

  int index = 0;

  bool tabBarTapped = false;
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: $styles.sizes.defaultAppBarSize,
          child: Container(
            height: $styles.sizes.defaultAppBarSize.height,
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: $styles.shadows.boxShadowSmall,
            ),
            child: Padding(
              padding: ($styles.insets.md, $styles.insets.md).insetsLeftRight,
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
                      borderRadius: BorderRadius.circular($styles.corners.xxlg),
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
          overlayChildrenOffset: const Offset(0.0, -10),
          duration: const Duration(milliseconds: 500),
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
              ImpulseIcons.transfer2,
              size: 30,
            ),
          ),
          // childSpacing: .4,
          children: const [
            SpeedChild(
              icon: Icons.file_upload_rounded,
            ),
            SpeedChild(
              icon: Icons.file_download_rounded,
            ),
          ],
        ),
        bottomNavigationBar: MyBottomNavBar(
          index: index,
          onChanged: (index) {
            this.index = index;
            setState(() {});
            _pageController.animateToPage(
              index,
              duration: $styles.times.pageTransition,
              curve: Curves.easeInOut,
            );
          },
        ),
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
