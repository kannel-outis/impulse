import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/views/transfer/widgets/transfer_list_tile.dart';

class SideBarProgressTile extends ConsumerStatefulWidget {
  const SideBarProgressTile({
    super.key,
  });

  @override
  ConsumerState<SideBarProgressTile> createState() =>
      _SideBarProgressTileState();
}

class _SideBarProgressTileState extends ConsumerState<SideBarProgressTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final connectionState = ref.watch(connectionStateProvider);
        if (connectionState == ConnectionState.connected) {
          return Consumer(
            builder: (context, ref, child) {
              final shareable = ref.watch(shareableItemsProvider);
              final downloadManager = ref.watch(downloadManagerProvider);

              ref.watch(receivableListItems);
              if (downloadManager.$2 != null) {
                return TransferListTile(
                  item: downloadManager.$2!,
                  mini: true,
                  mBps: ImpulseFileSize(downloadManager.$1).sizeToString,
                  height: 70,
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
                    ),
                  )
                  .toList();
              return inProgressItemsWidget.isEmpty
                  ? TransferListTile(
                      item: shareable.last,
                      mini: true,
                      height: 70,
                    )
                  : inProgressItemsWidget.first;
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
