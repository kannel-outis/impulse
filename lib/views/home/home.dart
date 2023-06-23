import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:impulse/app/app.dart';

import 'components/bottom_app_bar.dart';
import 'widgets/bottom_app_bar_icon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool tabBarTapped = false;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);
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
              const SizedBox(height: 40),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    AppsPage(),
                    ImagesPage(),
                    VideosPage(),
                  ],
                ),
              ),
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
        bottomNavigationBar: MyBottomAppBar(),
      ),
    );
  }
}

class VideosPage extends StatelessWidget {
  const VideosPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Row(
        children: [
          Expanded(
            child: Text("data 1"),
          ),
        ],
      ),
    );
  }
}

class ImagesPage extends StatelessWidget {
  const ImagesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
      child: Row(
        children: [
          Expanded(
            child: Text("data 1"),
          ),
        ],
      ),
    );
  }
}

class AppsPage extends StatelessWidget {
  const AppsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: $styles.colors.accentColor1,
      child: Row(
        children: [
          Expanded(
            child: Text("data 1"),
          ),
        ],
      ),
    );
  }
}
