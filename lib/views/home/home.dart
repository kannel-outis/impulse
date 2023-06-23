import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/views/files/file_manager.dart';
import 'package:impulse/views/home/widgets/app_item.dart';
import 'package:impulse/views/settings/settings_screen.dart';

import 'components/bottom_app_bar.dart';

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
        body: Padding(
          padding: ($styles.insets.md, 0.0).insets,
          child: PageView(
            controller: _pageController,
            // onPageChanged: (page) {
            //   index = page;
            //   setState(() {});
            // },
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Home(tabController: _tabController, tabs: tabs),
              const FileManagerScreen(),
              const SettingScreen(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // final dir = Directory("/system/fonts");
            // if (dir.existsSync()) {
            //   final list = dir.listSync();
            //   for (final l in list) {
            //     log(l.toString());
            //   }
            // }
          },
        ),
        bottomNavigationBar: MyBottomAppBar(
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
    return Column(
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
    );
  }
}
