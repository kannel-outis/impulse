import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' hide ConnectionState, Path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse/views/shared/padded_body.dart';
import 'package:impulse/views/shared/selectable_item_widget.dart';
import 'package:impulse_utils/impulse_utils.dart';

import 'widgets/file_manager_tile.dart';

class FileManagerScreen extends ConsumerStatefulWidget {
  final List<ImpulseFileEntity>? files;
  final Path? path;
  const FileManagerScreen({super.key, this.files, this.path});

  @override
  ConsumerState<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends ConsumerState<FileManagerScreen>
    with AutomaticKeepAliveClientMixin {
  List<ImpulseFileEntity> files = [];
  late final ImpulseDirectory? dir;

  @override
  void initState() {
    super.initState();

    if (isAndroid) {
      dir = widget.path == null
          ? null
          : ImpulseDirectory(
              directory: Directory(widget.path!.path),
            );
    } else {
      dir = ImpulseDirectory(
        directory: Directory(widget.path?.path ??
            "C:${Platform.pathSeparator}Users${Platform.pathSeparator}emirb${Platform.pathSeparator}Downloads${Platform.pathSeparator}"),
      );
    }
  }

  Future<List<ImpulseFileEntity>> _init_([ImpulseDirectory? dir]) async {
    if (widget.files != null) {
      files = widget.files!;
    } else {
      final controller = ref.read(fileManagerProvider);
      files = await controller.goToPathAsync(dir);
    }
    return files;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.path != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref.read(pathController.notifier).addPathToNav(widget.path!);
      });
    }
  }

  // List<String> get paths => widget.path!.path.split(Platform.pathSeparator);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final receiveables = ref.watch(receivableListItems);

    return WillPopScope(
      onWillPop: () async {
        final pathProvider = ref.watch(pathController.notifier);
        if (widget.path != null) {
          pathProvider.pop();
        }
        return true;
      },
      child: FutureBuilder<List<ImpulseFileEntity>>(
          future: _init_(dir),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data!.isEmpty) {
              return Center(
                child: Icon(
                  Icons.inventory_2,
                  size: $styles.sizes.prefixIconSize * 4,
                  color: $styles.colors.iconColor1,
                ),
              );
            }
            return PaddedBody(
              child: Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: $styles.times.med,
                      child: ListView.builder(
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          final item = files[index];
                          return SelectableItemWidget(
                            file: (item.fileSystemEntity is File)
                                ? item.fileSystemEntity as File
                                : null,
                            isSelectable: item is! ImpulseDirectory,
                            child: FileManagerTile(
                              item: item,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
