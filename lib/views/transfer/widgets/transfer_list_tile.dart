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
  final double? width;
  const TransferListTile({
    this.height = 100,
    this.mini = false,
    required this.item,
    this.mBps,
    super.key,
    this.width,
  });

  double get factor {
    const defaultHeight = 100;
    return height / defaultHeight;
  }

  double get paddingBtwFileImage => 10;
  double get fileImageSize => 70 * factor;
  double get tilePadding => $styles.insets.sm;

  double get _padding {
    /*
      *The padding here represents occupied spaces.
      *fileImageSize - space that the file icon image occupied
      *paddingBtwFileImage - is the padding between the file image and the file name
      *tilePadding - is the horizontal padding in the left right side of the tile
      *if tile is not mini, we want to add an additional padding 50 + another padding on the right(only)
      *where 50 is the size of the cancel icon box.

    */
    return (fileImageSize +
        paddingBtwFileImage +
        (tilePadding * 2) +
        (!mini ? 50 + $styles.insets.md : 0.0));
  }

  @override
  Widget build(BuildContext context) {
    return ItemListenableBuilder(
        listenable: item,
        builder: (context, percentage, state, child) {
          return Consumer(
            builder: (context, ref, child) {
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
                child: child,
              );
            },
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    print(state);
                    return Container(
                      height: height,
                      width: constraints.maxWidth * percentage,
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
                                    ? $styles.colors.folderColor2
                                        .withOpacity(.2)
                                    : Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(.2),
                        // boxShadow: $styles.shadows.boxShadowSmall,
                      ),
                    );
                  },
                ),
                LayoutBuilder(builder: (context, constraints) {
                  return Container(
                    height: height,
                    width: constraints.maxWidth,
                    margin: EdgeInsets.only(
                      bottom: mini ? 0 : $styles.insets.lg,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      // boxShadow: $styles.shadows.boxShadowSmall,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: tilePadding),
                      child: Row(
                        children: [
                          // Container(
                          //   height: fileImageSize,
                          //   width: fileImageSize,
                          //   decoration: const BoxDecoration(
                          //     image: DecorationImage(
                          //       image: AssetImage(
                          //         AssetsImage.android_icon_placeholder,
                          //       ),
                          //       fit: BoxFit.cover,
                          //     ),
                          //   ),
                          // ),
                          FilePlaceHolder(
                            ///Some items with [altName] do not contain mime type e.g apps
                            name: item.filePath,
                            size: fileImageSize,
                          ),
                          SizedBox(width: paddingBtwFileImage),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: constraints.maxWidth - _padding,
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
                                    SizedBox(
                                      width: constraints.maxWidth - _padding,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.itemSize.sizeToString,
                                            style: $styles.text.body,
                                          ),
                                          if (mBps != null &&
                                              constraints.maxWidth > 250)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: Text(
                                                mBps!,
                                                style:
                                                    $styles.text.body.copyWith(
                                                  color: Colors.green,
                                                ),
                                              ),
                                            )
                                          else
                                            const SizedBox()
                                        ],
                                      ),
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
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .tertiary,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        });
  }
}
