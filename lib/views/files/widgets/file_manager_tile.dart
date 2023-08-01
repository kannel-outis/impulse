import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/file_manager/file_manager_controller.dart';
import 'package:impulse_utils/impulse_utils.dart';

class FileManagerTile extends ConsumerStatefulWidget {
  final ImpulseFileEntity item;
  const FileManagerTile({super.key, required this.item});

  @override
  ConsumerState<FileManagerTile> createState() => _FileManagerTileState();
}

class _FileManagerTileState extends ConsumerState<FileManagerTile> {
  double _itemTileWidth({double padding = 0}) {
    return (MediaQuery.of(context).size.width -
        ($styles.insets.md * 2) -
        ($styles.sizes.prefixIconSize + padding));
  }

  double get leftItemPadding => 15;
  @override
  Widget build(BuildContext context) {
    final fileManagerController = ref.watch(fileManagerProvider);

    return GestureDetector(
      onTap: widget.item.isFolder
          ? () {
              // if (widget.item.isFolder) {
              final files = fileManagerController.goToPath(widget.item);
              context.push(
                  "${ImpulseRouter.routes.folder}/files/${widget.item.fileSystemEntity.path}",
                  extra: widget.item.fileSystemEntity.path);
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
            _getPreffix(widget.item),
            SizedBox(width: leftItemPadding),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _itemTileWidth(padding: leftItemPadding * 4),
                  child: Text(
                    widget.item.name,
                    overflow: TextOverflow.ellipsis,
                    style: $styles.text.body,
                  ),
                ),
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
          ],
        ),
      ),
    );
  }

  Widget _getPreffix(ImpulseFileEntity file) {
    // log("${file.fileType?.isImage.toString()}");
    if (file.fileType != null && file.fileType!.isImage) {
      if (!Platform.isAndroid) {
        return _buildPlaceholder(AssetsImage.image_placeholder);
      }
      return MediaThumbnail(
        file: (file as ImpulseFile).file.path,
        isVideo: false,
        size: const Size(150, 150),
        placeHolder: _buildPlaceholder(AssetsImage.image_placeholder),
      );
    }
    if (file.fileType != null && file.fileType!.isVideo) {
      if (!Platform.isAndroid) {
        return _buildPlaceholder(AssetsImage.video_placeholder);
      }
      return MediaThumbnail(
        file: (file as ImpulseFile).file.path,
        isVideo: true,
        placeHolder: _buildPlaceholder(AssetsImage.video_placeholder),
      );
    }
    return _buildFolderPreffix();
  }

  Container _buildPlaceholder(String asset) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(asset), fit: BoxFit.cover),
      ),
    );
  }

  Container _buildFolderPreffix() {
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
