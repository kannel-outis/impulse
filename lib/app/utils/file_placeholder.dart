import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:mime/mime.dart';

class FilePlaceHolder extends StatelessWidget {
  final String name;
  final bool isFolder;
  final double? folderSize;
  const FilePlaceHolder({
    super.key,
    required this.name,
    this.isFolder = false,
    this.folderSize,
  });

  @override
  Widget build(BuildContext context) {
    return isFolder ? _buildFolderPreffix() : _getPreffix(name);
  }

  Widget _getPreffix(String name) {
    // log("${file.fileType?.isImage.toString()}");
    bool _(String type) {
      if (lookupMimeType(name) == null) {
        return false;
      } else {
        return lookupMimeType(name)!.contains(type);
      }
    }

    if (_("image")) {
      return _buildPlaceholder(AssetsImage.pic_placeholder);
    } else if (_("video")) {
      return _buildPlaceholder(AssetsImage.mp4_placeholder);
    } else if (_("android")) {
      return _buildPlaceholder(AssetsImage.android_icon_placeholder);
    } else if (_("zip")) {
      return _buildPlaceholder(AssetsImage.zip_placeholder);
    } else if (_("audio")) {
      return _buildPlaceholder(AssetsImage.mp3_placeholder);
    } else if (_("word")) {
      return _buildPlaceholder(AssetsImage.word_placeholder);
    } else if (_("excel")) {
      return _buildPlaceholder(AssetsImage.excel_placeholder);
    } else if (_("pdf")) {
      return _buildPlaceholder(AssetsImage.pdf_placeholder);
    }
    return _buildPlaceholder(AssetsImage.unknown_placeholder);
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
      height: folderSize ?? 45,
      width: folderSize ?? 45,
      decoration: BoxDecoration(
        color: $styles.colors.folderColor2,
        borderRadius: BorderRadius.circular(
            ((folderSize ?? 45) / 45) * ($styles.corners.md)),
      ),
      child: Icon(
        isFolder ? ImpulseIcons.bxs_folder : Icons.file_copy,
        size: ((folderSize ?? 45) / 45) * ($styles.sizes.prefixIconSize / 2),
        color: Colors.white,
      ),
    );
  }
}
