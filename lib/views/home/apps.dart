part of 'home.dart';

class AppsPage extends ConsumerStatefulWidget {
  const AppsPage({
    super.key,
  });

  @override
  ConsumerState<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends ConsumerState<AppsPage>
    with AutomaticKeepAliveClientMixin {
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

    return SingleChildScrollView(
      child: Wrap(
        children: [
          for (final app in homeController.applications
              .where((element) => element.isSystemApp == false))
            SelectableItemWidget(
              app: app,
              isSelectable: true,
              child: AppItem(app: app),
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
