import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/views/transfer/transfer_page.dart';

import 'transfer_list_tile.dart';

class FullTransferPage extends ConsumerStatefulWidget {
  const FullTransferPage({
    super.key,
  });

  @override
  ConsumerState<FullTransferPage> createState() => _FullTransferPageState();
}

class _FullTransferPageState extends ConsumerState<FullTransferPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: $styles.screenSize.height - View.of(context).padding.top,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Theme.of(context).colorScheme.primary,
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Expanded(child: Container()),
                SizedBox(
                  width: 250,
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelPadding: EdgeInsets.only(
                      bottom: $styles.insets.xs,
                      right: $styles.insets.md,
                      top: $styles.insets.sm,
                    ),
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    indicatorColor: $styles.colors.fontColor1,
                    labelColor: $styles.colors.fontColor1,
                    indicatorWeight: 2,
                    padding: EdgeInsets.zero,
                    tabs: [
                      Consumer(builder: (contex, ref, child) {
                        final shareables = ref.watch(shareableItemsProvider);
                        return TabWidget(label: "Sent", items: shareables);
                      }),
                      Consumer(builder: (context, ref, child) {
                        final receaivables = ref.watch(receivableListItems);

                        ///to watch changes in the receevables and and rebuild the consumer
                        ref.watch(downloadManagerProvider);
                        return TabWidget(
                          label: "Received",
                          items: receaivables,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final shareable = ref.watch(shareableItemsProvider);
                    return ListView(
                      ///size of each tile and margin
                      physics: ((100 + $styles.insets.lg) * shareable.length >
                              MediaQuery.of(context).size.height - 200)
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      children: [
                        ...List.generate(
                          shareable.length,
                          (index) => TransferListTile(item: shareable[index]),
                        ).reversed,
                      ],
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final receivables = ref.watch(receivableListItems);
                    return ListView(
                      physics: ((100 + $styles.insets.lg) * receivables.length >
                              MediaQuery.of(context).size.height - 200)
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      children: [
                        ...List.generate(
                          receivables.length,
                          (index) => TransferListTile(item: receivables[index]),
                        ).reversed,
                      ],
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
