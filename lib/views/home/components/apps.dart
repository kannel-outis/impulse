part of '../home.dart';

class AppsPage extends ConsumerStatefulWidget {
  const AppsPage({
    super.key,
  });

  @override
  ConsumerState<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends ConsumerState<AppsPage>
    with AutomaticKeepAliveClientMixin {
  List<Application> get list => ref
      .read(homeProvider)
      .applications
      .where((element) => element.isSystemApp == false)
      .toList();

  double _appBox() {
    final screenWidth = MediaQuery.of(context).size.width;

    ///The total width of device minus the padding on both side
    ///divided by the number of items we'd like to fit in a row
    return (screenWidth - ($styles.insets.md * 2)) / 4;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final homeController = ref.watch(homeProvider);
    // print(homeController.applications.length);
    if (homeController.isGettingAllApplications) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    //  (MediaQuery.of(context).size.width / 100) * 20

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: _appBox(),
            childAspectRatio: ((constraints.maxWidth) /
                (MediaQuery.of(context).size.height * .6)),
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return SelectableItemWidget(
              app: list[index],
              isSelectable: true,
              child: AppItem(
                app: list[index],
              ),
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
