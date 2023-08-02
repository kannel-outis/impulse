import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    if (isAndroid) {
      final dir = widget.path == null
          ? null
          : ImpulseDirectory(
              directory: Directory(widget.path!),
            );
      _init_(dir);
    } else {
      final dir = ImpulseDirectory(
        directory: Directory(widget.path ??
            "C:${Platform.pathSeparator}Users${Platform.pathSeparator}emirb${Platform.pathSeparator}Downloads${Platform.pathSeparator}"),
      );
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

  List<String> get paths => widget.path!.split(Platform.pathSeparator);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final receiveables = ref.watch(receivableListItems);

    return PaddedBody(
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: double.infinity,
            child: SizedBox(
              width:
                  MediaQuery.of(context).size.width - ($styles.insets.md * 2),
              child: SingleChildScrollView(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                reverse: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.path != null)
                      for (var i = 0; i < paths.length; i++)
                        GestureDetector(
                          onTap: () {
                            context.go("${ImpulseRouter.routes.folder}/files",
                                extra: paths[i]);
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: ($styles.insets.md, $styles.insets.md)
                                    .insets,
                                child: Text(paths[i], style: $styles.text.body),
                              ),
                              i != (paths.length - 1)
                                  ? Text(">", style: $styles.text.body)
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: files.isEmpty
                ? Icon(
                    Icons.inventory_2,
                    size: $styles.sizes.prefixIconSize * 4,
                    color: $styles.colors.iconColor1,
                  )
                : ListView.builder(
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
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
