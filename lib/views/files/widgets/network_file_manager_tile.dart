import 'package:flutter/material.dart' hide Path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse_utils/impulse_utils.dart';

class NetworkFileManagerTile extends ConsumerStatefulWidget {
  final NetworkImpulseFileEntity item;
  const NetworkFileManagerTile({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<NetworkFileManagerTile> createState() =>
      _NetworkFileManagerTileState();
}

class _NetworkFileManagerTileState
    extends ConsumerState<NetworkFileManagerTile> {
  // double _itemTileWidth({double padding = 0}) {
  //   return (MediaQuery.of(context).size.width -
  //       ($styles.insets.md * 2) -
  //       ($styles.sizes.prefixIconSize + padding));
  // }

  ImpulseFileStorage get asStorageFile => widget.item as ImpulseFileStorage;

  double get leftItemPadding => 15;
  @override
  Widget build(BuildContext context) {
    // final fileManagerController = ref.watch(fileManagerProvider);

    return GestureDetector(
      onTap: widget.item.isFolder
          ? () {
              // if (widget.item.isFolder) {
              // final files = fileManagerController.goToPath(widget.item);

              context.pushNamed(
                "NetworkfilesPath",
                pathParameters: {
                  "path": widget.item.path,
                  "username": widget.item.serverInfo.user.name,
                },
                extra: widget.item.name,
                // extra: widget.item.fileSystemEntity.path,
              );
              // }
            }
          : null,
      child: Container(
        height: 70,
        width: double.infinity,
        color: Colors.transparent,
        margin: $styles.insets.sm.insetsBottom,
        child: Row(
          children: [
            FilePlaceHolder(
              name: widget.item.name,
              isFolder: widget.item.isFolder,
            ),
            SizedBox(width: leftItemPadding),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    // width: _itemTileWidth(padding: leftItemPadding * 4),
                    child: Text(
                      widget.item.name,
                      overflow: TextOverflow.ellipsis,
                      style: $styles.text.body,
                    ),
                  ),
                  Text(
                    widget.item.isFolder
                        ? widget.item.modified.toString().cutTimeDateString
                        : widget.item.sizeToString,
                    style: $styles.text.body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
