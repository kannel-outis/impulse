import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/services/online/shared/transfer/item.dart';
import 'package:impulse/views/shared/padded_body.dart';
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
          TransferPageTopAppBar(
            tabController: _tabController,
            durationBuilder: (tab) {
              return Consumer(
                builder: (context, ref, child) {
                  final uploadManager = ref.watch(uploadManagerProvider);
                  final downloadManager = ref.watch(downloadManagerProvider);
                  if (tab.isReceived) {
                    return downloadManager.mBps == 0
                        ? const SizedBox()
                        : MBps(mbps: downloadManager);
                  } else {
                    return uploadManager.mBps == 0
                        ? const SizedBox()
                        : MBps(mbps: uploadManager);
                  }
                },
              );
            },
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              return TabBarView(
                controller: _tabController,
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final shareable =
                          ref.watch(shareableItemsProvider).reversed.toList();
                      return ListView.builder(
                        ///size of each tile and margin
                        physics: ((100 + $styles.insets.lg) * shareable.length >
                                constraints.maxHeight - 200)
                            ? const AlwaysScrollableScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        // children: [
                        //   ...List.generate(
                        //     shareable.length,
                        //     (index) => TransferListTile(item: shareable[index]),
                        //   ).reversed,
                        // ],
                        // reverse: true,
                        itemCount: shareable.length,
                        itemBuilder: (context, index) {
                          return TransferListTile(item: shareable[index]);
                        },
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final receivables =
                          ref.watch(receivableListItems).reversed.toList();
                      return ListView.builder(
                        physics:
                            ((100 + $styles.insets.lg) * receivables.length >
                                    constraints.maxHeight - 200)
                                ? const AlwaysScrollableScrollPhysics()
                                : const NeverScrollableScrollPhysics(),
                        itemCount: receivables.length,
                        itemBuilder: (context, index) {
                          return TransferListTile(item: receivables[index]);
                        },
                      );
                    },
                  ),
                ],
              );
            }),
          )
        ],
      ),
    );
  }
}

class MBps extends StatelessWidget {
  const MBps({
    super.key,
    required this.mbps,
  });

  final ({Item? currentDownload, int mBps, Duration remainingTime}) mbps;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!kReleaseMode)
          Text(
            "Remaining Time: ${mbps.remainingTime.toString().split(".").first}",
            style: $styles.text.h3.copyWith(
              color: $styles.colors.themeLight.scaffoldBackgroundColor,
            ),
          ),
        Text(
          ImpulseFileSize(mbps.mBps).sizeToString,
          style: $styles.text.body.copyWith(
            color: $styles.colors.themeLight.scaffoldBackgroundColor,
          ),
        ),
      ],
    );
  }
}

enum _Tab {
  received,
  sent;

  const _Tab();

  bool get isReceived => this == _Tab.received;
}

class TransferPageTopAppBar extends StatefulWidget {
  // ignore: library_private_types_in_public_api
  final Widget Function(_Tab)? durationBuilder;

  const TransferPageTopAppBar({
    super.key,
    required TabController tabController,
    this.durationBuilder,
  }) : _tabController = tabController;

  final TabController _tabController;

  @override
  State<TransferPageTopAppBar> createState() => _TransferPageTopAppBarState();
}

class _TransferPageTopAppBarState extends State<TransferPageTopAppBar> {
  _Tab _tab = _Tab.sent;
  @override
  void initState() {
    super.initState();
    widget._tabController.addListener(() {
      final index = widget._tabController.index;
      _tab = index == 0 ? _Tab.sent : _Tab.received;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Expanded(
            child: PaddedBody(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    widget.durationBuilder?.call(_tab) ?? const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 250,
            child: TabBar(
              controller: widget._tabController,
              indicatorSize: TabBarIndicatorSize.label,
              // physics: NeverScrollableScrollPhysics(),
              labelPadding: EdgeInsets.only(
                bottom: $styles.insets.xs,
                right: $styles.insets.md,
                top: $styles.insets.sm,
              ),
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              indicatorColor: Theme.of(context).colorScheme.secondary,
              labelColor: $styles.colors.themeLight.scaffoldBackgroundColor,
              unselectedLabelColor: $styles
                  .colors.themeLight.scaffoldBackgroundColor
                  .withOpacity(.5),
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
    );
  }
}
