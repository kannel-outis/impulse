import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide ConnectionState, Path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  ImpulseDirectory? dir;
  bool selectAll = false;

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
      // "C:${Platform.pathSeparator}Users${Platform.pathSeparator}emirb${Platform.pathSeparator}Downloads${Platform.pathSeparator}"
      if (widget.path != null) {
        dir = ImpulseDirectory(
          directory: Directory(widget.path!.path),
        );
      } else {
        if (Configurations.instance.rootFolderLocation == null) {
          dir = null;
        } else {
          dir = ImpulseDirectory(
            directory: Directory(Configurations.instance.rootFolderLocation!),
          );
        }
      }
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
      child: dir == null && !isAndroid
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Icon(
                    Icons.inventory_2,
                    size: $styles.sizes.prefixIconSize * 4,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final path = await FilePicker.platform.getDirectoryPath();
                    if (path != null) {
                      dir = ImpulseDirectory(directory: Directory(path));
                      setState(() {});
                      Configurations.instance.setRootFolderLocation(path);
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 120,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(
                          $styles.corners.sm,
                        )),
                    child: Center(
                      child: Text(
                        "Choose Folder",
                        style: $styles.text.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : FutureBuilder<List<ImpulseFileEntity>>(
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
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  );
                }
                return PaddedBody(
                  child: Stack(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            children: [
                              if ((widget.path != null || !isAndroid) &&
                                  ref
                                      .watch(selectingItemStateProvider)
                                      .isSelectingApp)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      child: Consumer(
                                        builder: (context, ref, child) {
                                          return child!;
                                        },
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () {
                                              selectAll = !selectAll;
                                              final selectedItems = ref.read(
                                                  selectedItemsProvider
                                                      .notifier);
                                              setState(() {});
                                              if (selectAll) {
                                                for (var file in files) {
                                                  if (!file.isFolder) {
                                                    selectedItems.addSelected(
                                                      // path: file?.appPath,
                                                      file:
                                                          file.fileSystemEntity
                                                              as File,
                                                      // altName: widget.app?.appName,
                                                    );
                                                  }
                                                }
                                              } else {
                                                for (var file in files) {
                                                  if (!file.isFolder) {
                                                    selectedItems
                                                        .removeSelected(
                                                      // path: file?.appPath,
                                                      file:
                                                          file.fileSystemEntity
                                                              as File,
                                                      // altName: widget.app?.appName,
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                            child: Container(
                                              padding: (
                                                $styles.insets.xxs,
                                                $styles.insets.xs
                                              ).insetsLeftRight,
                                              // color: Theme.of(context).colorScheme.tertiary,
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    value: selectAll,
                                                    checkColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .surface,
                                                    fillColor: !selectAll
                                                        ? const MaterialStatePropertyAll(
                                                            Colors.transparent)
                                                        : MaterialStatePropertyAll(
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary),
                                                    onChanged: null,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "Select all",
                                                    style: $styles
                                                        .text.bodySmall
                                                        .copyWith(
                                                            // color: Theme.of(context).colorScheme.surface,
                                                            ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              AnimatedSwitcher(
                                duration: $styles.times.med,
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    return SizedBox(
                                      ///if path is null, that means we are at the root
                                      height: _getHeight(ref, constraints) -
                                          ((widget.path != null ||
                                                      !isAndroid) &&
                                                  ref
                                                      .watch(
                                                          selectingItemStateProvider)
                                                      .isSelectingApp
                                              ? 30
                                              : 0),
                                      width: constraints.maxWidth,
                                      child: child,
                                    );
                                  },
                                  child: ListView.separated(
                                    itemCount: files.length,
                                    physics: isAndroid && widget.path == null
                                        ? const NeverScrollableScrollPhysics()
                                        : null,
                                    separatorBuilder: (context, index) {
                                      return SizedBox(
                                          height: $styles.insets.sm);
                                    },
                                    itemBuilder: (context, index) {
                                      final item = files[index];
                                      return SelectableItemWidget(
                                        file: (item.fileSystemEntity is File)
                                            ? item.fileSystemEntity as File
                                            : null,
                                        isSelectable: item is! ImpulseDirectory,
                                        onChanged: (onSelect) {
                                          if (onSelect == false) {
                                            selectAll = false;
                                            setState(() {});
                                          }
                                        },
                                        child: FileManagerTile(
                                          item: item,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (isAndroid && widget.path == null)
                                SizedBox(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: (
                                          $styles.insets.xxl,
                                          $styles.insets.sm
                                        ).insetsTopBottom,
                                        child: Divider(
                                          thickness: .5,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary
                                              .withOpacity(.2),
                                        ),
                                      ),
                                      Consumer(
                                        builder: (context, ref, child) {
                                          if (ref
                                              .watch(connectionStateProvider)
                                              .isConnected) {
                                            return InkWell(
                                              onTap: () {
                                                context.pushNamed(
                                                  "NetworkfilesPath",
                                                  pathParameters: {
                                                    "path": "root",
                                                    "username": ref
                                                        .read(
                                                            connectUserStateProvider)!
                                                        .user
                                                        .name,
                                                  },
                                                );
                                              },
                                              child: Container(
                                                height: 50,
                                                width: double.infinity,
                                                color: Colors.transparent,
                                                child: Center(
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                          width: $styles
                                                              .insets.sm),
                                                      const FilePlaceHolder(
                                                        name: "",
                                                        isFolder: true,
                                                      ),
                                                      SizedBox(
                                                          width: $styles
                                                              .insets.sm),
                                                      Text(
                                                        ref
                                                            .read(
                                                                connectUserStateProvider)!
                                                            .user
                                                            .name,
                                                        style:
                                                            $styles.text.body,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          return const SizedBox();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      Positioned(
                        right: 0,
                        child: Container(),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  // ignore: no_leading_underscores_for_local_identifiers
  double _getHeight(WidgetRef _ref, BoxConstraints constraints) {
    //if path == null , that means we are already in the root of the files
    if (isAndroid && widget.path == null) {
      //we dont want the height to take the whole screen and only set it based on the length of the files
      //which cant be more than 2 or 3. so that we can utilize the remaining space
      return (70.0 * files.length);
    } else if (_ref.watch(connectionStateProvider).isConnected &&
        MediaQuery.of(context).size.width <= $styles.tabletLg) {
      return constraints.maxHeight - 70;
    } else {
      return constraints.maxHeight;
    }
  }
}
