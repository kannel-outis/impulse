import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';
import 'package:impulse/views/shared/impulse_ink_well.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: Text(
          "History",
          style: $styles.text.h3.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ValueListenableBuilder(
              valueListenable:
                  Hive.box<HiveItem>(HiveInit.shareableItemsBox).listenable(),
              builder: (context, shareable, child) {
                return ValueListenableBuilder(
                  valueListenable:
                      Hive.box<HiveItem>(HiveInit.receiveableItemsBox)
                          .listenable(),
                  builder: (context, receivable, child) {
                    final list = [
                      ...receivable.values.toList(),
                      ...shareable.values.toList()
                    ];
                    list.sort((a, b) {
                      return a.endTime.compareTo(b.endTime);
                    });
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: $styles.insets.sm);
                      },
                      itemBuilder: (context, index) {
                        // list.reversed.toList()[index].name
                        final item = list.reversed.toList()[index];
                        return Container(
                          height: 70,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: $styles.insets.sm),
                          // color: _color(item.state, context),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return ImpulseInkWell(
                              onTap: () {},
                              child: Row(
                                children: [
                                  FilePlaceHolder(
                                    name: item.path,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: constraints.maxWidth -
                                            (($styles.insets.sm * 2) + 50),
                                        child: Text(
                                          item.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: $styles.text.body,
                                        ),
                                      ),
                                      SizedBox(
                                        width: constraints.maxWidth -
                                            (($styles.insets.sm * 2) + 50),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              // width: constraints.maxWidth -
                                              //     (($styles.insets.sm * 2) + 50),
                                              child: Text(
                                                item.itemSize.sizeToString,
                                                overflow: TextOverflow.ellipsis,
                                                style: $styles.text.body,
                                              ),
                                            ),
                                            SizedBox(
                                              // width: constraints.maxWidth -
                                              //     (($styles.insets.sm * 2) + 50),
                                              child: Text(
                                                item.state.label,
                                                overflow: TextOverflow.ellipsis,
                                                style: $styles.text.body,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }),
                        );
                      },
                    );
                  },
                );
              }),
        ),
      ),
    );
  }

  // Color _color(IState state, BuildContext context) {
  //   return Colors.transparent;
  //   if (state.isWaiting) {
  //     return const Color(0xff9D9D9D).withOpacity(.2);
  //   } else if (state.isFailed) {
  //     return Colors.red.withOpacity(.2);
  //   } else if (state.isPaused) {
  //     return $styles.colors.folderColor2.withOpacity(.2);
  //   } else {
  //     return Theme.of(context).colorScheme.primary.withOpacity(.2);
  //   }
  // }
}
