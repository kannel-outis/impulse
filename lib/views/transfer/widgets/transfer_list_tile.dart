import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
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
    return ItemListenableBuilder(
        listenable: item,
        builder: (context, percentage, state) {
          return Stack(
            children: [
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
                child: Row(
                  children: [
                    const SizedBox(width: 20),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item is ReceiveableItem
                                ? (item as ReceiveableItem).altName ??
                                    item.fileName ??
                                    item.name
                                : item.fileName ?? item.name,
                            style: $styles.text.body,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.itemSize.sizeToString,
                                style: $styles.text.body,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Text(
                                  mBps != null ? mBps! : state.label,
                                  style: $styles.text.body.copyWith(
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: height,
                width: MediaQuery.of(context).size.width > 700
                    ? 700 * percentage
                    : MediaQuery.of(context).size.width * percentage,
                constraints: mini ? null : const BoxConstraints(maxWidth: 700),
                margin: EdgeInsets.only(
                  bottom: mini ? 0 : 30,
                ),
                decoration: BoxDecoration(
                  color: $styles.colors.secondaryColor.withOpacity(.2),
                  // boxShadow: $styles.shadows.boxShadowSmall,
                ),
              ),
            ],
          );
        });
  }
}
