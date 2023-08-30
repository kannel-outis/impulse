import 'package:flutter/material.dart' hide Path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
// import 'package:impulse/controllers/file_manager/file_manager_controller.dart';
import 'package:impulse_utils/impulse_utils.dart';

class FileManagerTile extends ConsumerStatefulWidget {
  final ImpulseFileEntity item;
  const FileManagerTile({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<FileManagerTile> createState() => _FileManagerTileState();
}

class _FileManagerTileState extends ConsumerState<FileManagerTile> {
  double _itemTileWidth({double padding = 0}) {
    return (MediaQuery.of(context).size.width -
        ($styles.insets.md * 2) -
        ($styles.sizes.prefixIconSize + padding));
  }

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
                "filesPath",
                pathParameters: {"path": widget.item.fileSystemEntity.path},
                // extra: widget.item.fileSystemEntity.path,
              );
              // }
            }
          : null,
      child: Container(
        height: 70,
        width: double.infinity,
        color: Colors.transparent,
        // margin: $styles.insets.sm.insetsBottom,
        child: Row(
          children: [
            _getPreffix(widget.item),
            SizedBox(width: leftItemPadding),
            if (widget.item is ImpulseFileStorage)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: _itemTileWidth(padding: leftItemPadding * 4),
                      child: Text(
                        asStorageFile.type.label,
                        overflow: TextOverflow.ellipsis,
                        style: $styles.text.body,
                      ),
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Used: ${asStorageFile.usedSizeToFileSize.sizeToString}",
                          style: $styles.text.body,
                        ),
                        SizedBox(width: $styles.insets.xl),
                        Text(
                          "Available: ${asStorageFile.remainingSizeToFileSize.sizeToString}",
                          style: $styles.text.body,
                        ),
                        SizedBox(width: $styles.insets.xl),
                        Text(
                          "Total: ${asStorageFile.totalSizeToFileSize.sizeToString}",
                          style: $styles.text.body,
                        ),
                      ],
                    )
                  ],
                ),
              )
            else
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(builder: (context, constraints) {
                      return SizedBox(
                        // width: _itemTileWidth(padding: leftItemPadding * 4),
                        width: constraints.maxWidth - 40,
                        child: Text(
                          widget.item.name,
                          overflow: TextOverflow.ellipsis,
                          style: $styles.text.body,
                        ),
                      );
                    }),
                    Text(
                      widget.item.isFolder
                          ? widget.item.fileSystemEntity
                              .statSync()
                              .modified
                              .toString()
                              .cutTimeDateString
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

  Widget _getPreffix(ImpulseFileEntity file) {
    if (file.isFolder) {
      return _buildFolderPreffix();
    }
    if (file.fileType == null) {
      return const FilePlaceHolder(name: "unknown");
    }
    if (file.fileType!.isImage) {
      if (!isAndroid) {
        return FilePlaceHolder(name: file.name);
      }
      return MediaThumbnail(
        file: (file as ImpulseFile).file.path,
        isVideo: false,
        size: const Size(150, 150),
        placeHolder: FilePlaceHolder(name: file.name),
      );
    }
    if (file.fileType!.isVideo) {
      if (!isAndroid) {
        return FilePlaceHolder(name: file.name);
      }
      return MediaThumbnail(
        file: (file as ImpulseFile).file.path,
        isVideo: true,
        placeHolder: FilePlaceHolder(name: file.name),
      );
    } else {
      return FilePlaceHolder(name: file.name);
    }
  }

  Container _buildFolderPreffix() {
    if (widget.item.isRoot) {
      return Container(
        height: 45,
        width: 45,
        alignment: Alignment.center,
        child: Icon(
          (widget.item as ImpulseFileStorage).type == FileStorageType.Internal
              ? Icons.phone_android_sharp
              : Icons.sd_card_outlined,
          color: Theme.of(context).colorScheme.tertiary,
          size: 40.scale,
        ),
      );
    }
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: $styles.colors.folderColor2,
        borderRadius: BorderRadius.circular($styles.corners.md),
      ),
      child: Icon(
        widget.item.isFolder ? ImpulseIcons.bxs_folder : Icons.file_copy,
        size: $styles.sizes.prefixIconSize / 2,
        color: Colors.white,
      ),
    );
  }
}
