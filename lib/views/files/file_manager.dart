import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/views/shared/padded_body.dart';
import 'package:impulse/views/shared/selectable_item_widget.dart';
import 'package:impulse_utils/impulse_utils.dart';

import 'widgets/file_manager_tile.dart';

class FileManagerScreen extends ConsumerStatefulWidget {
  final List<ImpulseFileEntity>? files;
  final String? path;
  const FileManagerScreen({super.key, this.files, this.path});

  @override
  ConsumerState<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends ConsumerState<FileManagerScreen>
    with AutomaticKeepAliveClientMixin {
  List<ImpulseFileEntity> files = [];

  @override
  void initState() {
    super.initState();
    if (isAndroid) {
      _init_();
    } else {
      final dir = ImpulseDirectory(
          directory: Directory(widget.path ?? "C:/Users/emirb/Downloads/"));
      _init_(dir);
    }
  }

  void _init_([ImpulseDirectory? dir]) {
    if (widget.files != null) {
      files = widget.files!;
      setState(() {});
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final controller = ref.read(fileManagerProvider);
        files = controller.goToPath(dir);
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final receiveables = ref.watch(receivableListItems);

    if (files.isEmpty) {
      return Center(
        child: InkWell(
          onTap: () {
            // if (ref.read(alertStateNotifier) == false) {
            //   ref.read(alertStateNotifier.notifier).updateState(true);
            //   return;
            // }
            // ref.read(alertStateNotifier.notifier).updateState(false);

            // ref
            //     .read(connectionStateProvider.notifier)
            //     .setState(ConnectionState.connected);
          },
          child: Icon(
            Icons.inventory_2,
            size: $styles.sizes.prefixIconSize * 4,
            color: $styles.colors.iconColor1,
          ),

          ///for testing purpose
          // child: receiveables.isNotEmpty
          //      ListView.builder(
          //         itemCount: receiveables.length,
          //         itemBuilder: (context, index) {
          //           return ListTile(
          //             title: Text(
          //               receiveables[index].fileSize.toString(),
          //             ),
          //           );
          //         },
          //       )
          //     : null,
        ),
      );
    }
    return PaddedBody(
      child: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final item = files[index];
          return SelectableItemWidget(
            file: (item.fileSystemEntity is File)
                ? item.fileSystemEntity as File
                : null,
            child: FileManagerTile(item: item),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
