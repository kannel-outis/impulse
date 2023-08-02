import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/services/services.dart';

import 'item_listenable_builder.dart';

class TransferListTile extends StatelessWidget {
  final double height;
  final bool mini;
  final String? mBps;
  final Item item;
  const TransferListTile({
    this.height = 100,
    this.mini = false,
    required this.item,
    this.mBps,
    super.key,
  });

  double get factor {
    const defaultHeight = 100;
    return height / defaultHeight;
  }

  @override
  Widget build(BuildContext context) {
    print(item.homeDestination);
    return ItemListenableBuilder(
        listenable: item,
        builder: (context, percentage, state) {
          return Consumer(builder: (context, ref, child) {
            return GestureDetector(
              onTap: (mini)
                  ? null
                  : () async {
                      if (item is ReceiveableItem &&
                          (state.isInProgress || state.isPaused)) {
                        if (item is ReceiveableItem && !state.isWaiting) {
                          final downloadManager =
                              ref.read(downloadManagerProvider.notifier);
                          if (state.isInProgress) {
                            downloadManager.pauseCurrentDownload();
                          } else {
                            downloadManager.resumeDownload(
                              item as ReceiveableItem,
                            );
                          }
                        }
                      }
                    },
              child: Stack(
                children: [
                  Container(
                    height: height,
                    width: MediaQuery.of(context).size.width > 700
                        ? 700 * percentage
                        : MediaQuery.of(context).size.width * percentage,
                    constraints:
                        mini ? null : const BoxConstraints(maxWidth: 700),
                    margin: EdgeInsets.only(
                      bottom: mini ? 0 : 30,
                    ),
                    decoration: BoxDecoration(
                      color: state.isWaiting
                          ? const Color(0xff9D9D9D).withOpacity(.2)
                          : state.isFailed
                              ? Colors.red.withOpacity(.2)
                              : state.isPaused
                                  ? $styles.colors.folderColor2.withOpacity(.2)
                                  : $styles.colors.secondaryColor
                                      .withOpacity(.2),
                      // boxShadow: $styles.shadows.boxShadowSmall,
                    ),
                  ),
                  Container(
                    height: height,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(
                      bottom: mini ? 0 : $styles.insets.lg,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      // boxShadow: $styles.shadows.boxShadowSmall,
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: $styles.insets.sm),
                      child: Row(
                        children: [
                          Container(
                            height: 70 * factor,
                            width: 70 * factor,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  AssetsImage.android_icon_placeholder,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        item is ReceiveableItem
                                            ? (item as ReceiveableItem)
                                                    .altName ??
                                                item.fileName ??
                                                item.name
                                            : item.fileName ?? item.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: $styles.text.body,
                                      ),
                                    ),
                                    Text(
                                      item.itemSize.sizeToString,
                                      style: $styles.text.body,
                                    ),
                                  ],
                                ),
                                if (!state.isCompleted &&
                                    item is ReceiveableItem &&
                                    !mini)
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Consumer(
                                            builder: (context, ref, child) {
                                          return GestureDetector(
                                            onTap: () {
                                              // if (state.isInProgress) {
                                              //   item.cancel();
                                              // }
                                              final receivableProvider =
                                                  ref.read(receivableListItems
                                                      .notifier);
                                              receivableProvider
                                                  .cancelItemWithId(
                                                      item as ReceiveableItem);
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: const BoxDecoration(
                                                // borderRadius:
                                                //     BorderRadius.circular(100),
                                                color: Colors.transparent,
                                                // border: Border.all(
                                                //     color: Colors.red),
                                              ),
                                              margin: EdgeInsets.only(
                                                right: $styles.insets.sm,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  CupertinoIcons.clear,
                                                  size: 15.scale,
                                                  color:
                                                      $styles.colors.iconColor1,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                // if (mini == false &&
                                //     item is ReceiveableItem &&
                                //     (state.isInProgress || state.isPaused))
                                //   Consumer(
                                //     builder: (context, ref, child) {
                                //       return GestureDetector(
                                //         onTap: () async {
                                //           if (item is ReceiveableItem &&
                                //               !state.isWaiting) {
                                //             final downloadManager = ref.read(
                                //                 downloadManagerProvider.notifier);
                                //             if (state.isInProgress) {
                                //               downloadManager
                                //                   .pauseCurrentDownload();
                                //             } else {
                                //               downloadManager.resumeDownload(
                                //                 item as ReceiveableItem,
                                //               );
                                //             }
                                //           }
                                //         },
                                //         child: Container(
                                //           height: 30,
                                //           width: 80,
                                //           decoration: BoxDecoration(
                                //             color: state.isPaused
                                //                 ? state.isWaiting
                                //                     ? Colors.grey
                                //                     : Colors.green
                                //                 : $styles.colors.folderColor2,
                                //             borderRadius: BorderRadius.circular(
                                //               $styles.corners.sm,
                                //             ),
                                //           ),
                                //           alignment: Alignment.center,
                                //           child: Text(
                                //             state.isPaused
                                //                 ? "Resume"
                                //                 : state.isWaiting
                                //                     ? state.label
                                //                     : "Pause",
                                //             style: $styles.text.bodySmall.copyWith(
                                //               color: Colors.white,
                                //             ),
                                //           ),
                                //         ),
                                //       );
                                //     },
                                //   )
                                // else
                                if (mBps == null)
                                  const SizedBox()
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Text(
                                      mBps!,
                                      style: $styles.text.body.copyWith(
                                        color: Colors.green,
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }
}
