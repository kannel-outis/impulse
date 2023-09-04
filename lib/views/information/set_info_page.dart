// ignore_for_file: constant_identifier_names, unused_field,

import 'dart:io';

import 'package:file_picker/file_picker.dart' as picker;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/models/user.dart';
import 'package:impulse/views/shared/padded_body.dart';
import 'package:uuid/uuid.dart';

class SetInfoPage extends ConsumerStatefulWidget {
  final String? profileImage;
  final String? userName;
  const SetInfoPage({
    super.key,
    this.profileImage,
    this.userName,
  });

  @override
  ConsumerState<SetInfoPage> createState() => _SetInfoPageState();
}

enum _ImageType {
  Assets,
  File,

  _ImageTyper();

  bool get isFile => this == _ImageType.File;
  bool get isAsset => this == _ImageType.Assets;
}

class _SetInfoPageState extends ConsumerState<SetInfoPage> {
  late final PageController pageController;
  late final TextEditingController _controller;
  int currentIndex = 0;
  bool _hasAcceptedStoragePermission = true;

  bool _isLoadingImage = false;
  bool _isLoading = false;

  List<(_ImageType imageTyper, String path)> images = [
    (_ImageType.Assets, AssetsImage.DEFAULT_DISPLAY_IMAGE),
    (_ImageType.Assets, AssetsImage.DEFAULT_DISPLAY_IMAGE_2),
  ];

  @override
  initState() {
    super.initState();
    _controller = TextEditingController(text: widget.userName);
    // widget.profileImage!.contains("assets")
    if (widget.profileImage != null &&
        !images.contains((_ImageType.Assets, widget.profileImage))) {
      images.add(
        (_ImageType.File, widget.profileImage!),
      );
    }
    pageController = PageController(
      viewportFraction: .2,

      ///if profile image is null that means user is a first timer, start at 0
      ///if not, check if profile image is an asset image then start at the index position,
      ///if profile is not asset, start at the end of the image list, means profile file image is a file image
      initialPage: widget.profileImage == null
          ? 0
          : images.contains((_ImageType.Assets, widget.profileImage))
              ? images
                  .indexWhere((element) => element.$2 == widget.profileImage)
              : images.length - 1,
    );
    currentIndex = pageController.initialPage;
  }

  List<String> get imageExtensions => [
        "jpeg",
        "jpg",
        "png",
        "wepb",
      ];

  bool get _isFirstRun =>
      widget.userName == null && widget.profileImage == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFirstRun ? null : AppBar(),
      body: PaddedBody(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                // color: Colors.white,
                child: PageView(
                  controller: pageController,
                  // reverse: true,
                  // itemCount: assetImages.length,
                  physics: const BouncingScrollPhysics(),

                  onPageChanged: (currentIndex) {
                    this.currentIndex = currentIndex;
                    setState(() {});
                  },
                  children: [
                    ...List.generate(
                      images.length,
                      (index) => GestureDetector(
                        onTap: () {
                          pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: $styles.curves.defaultCurve,
                          );
                        },
                        child: ImageItemChild(
                          currentIndex: currentIndex,
                          assetImages: images,
                          index: index,
                        ),
                      ),
                    ),
                    MouseRegion(
                      cursor: currentIndex == images.length
                          ? SystemMouseCursors.click
                          : MouseCursor.defer,
                      child: GestureDetector(
                        onTap: () async {
                          if (_isLoadingImage) return;
                          if (currentIndex == images.length) {
                            final result =
                                await picker.FilePicker.platform.pickFiles(
                              allowCompression: true,
                              // allowedExtensions: imageExtensions,
                              allowMultiple: false,
                              type: picker.FileType.image,
                            );

                            if (result != null) {
                              _isLoadingImage = true;
                              setState(() {});
                              // final thumbNail = await Configurations
                              //     .instance.impulseUtils
                              //     .getMediaThumbNail(
                              //   file: result.paths.first!,
                              //   isVideo: false,
                              //   returnPath: true,
                              //   size: const Size(512, 384),
                              // );
                              images
                                  .add((_ImageType.File, result.paths.first!));
                              _isLoadingImage = false;
                              setState(() {});
                            }

                            return;
                          }
                          pageController.animateToPage(
                            images.length,
                            duration: const Duration(milliseconds: 500),
                            curve: $styles.curves.defaultCurve,
                          );
                        },
                        child: ImageItemChild(
                          currentIndex: currentIndex,
                          assetImages: images,
                          index: images.length,
                          child: Center(
                            child: _isLoadingImage
                                ? const CircularProgressIndicator(
                                    strokeWidth: 1,
                                  )
                                : Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: $styles.insets.md,
                                      vertical: $styles.insets.sm,
                                    ),
                                    child: FittedBox(
                                      child: Text(
                                        "PickImage",
                                        style: $styles.text.bodySmall,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: $styles.insets.lg),
                child: TextFormField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  cursorColor: Theme.of(context).colorScheme.tertiary,
                  decoration: InputDecoration(
                    hintText: "Enter Alias",
                    hintStyle: $styles.text.h3.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    border: InputBorder.none,
                    // enabledBorder: UnderlineInputBorder(
                    //   borderSide: BorderSide(
                    //     color: $styles.colors.fontColor2,
                    //   ),
                    // ),
                    // focusedBorder: UnderlineInputBorder(
                    //   borderSide: BorderSide(
                    //     color: Theme.of(context).colorScheme.tertiary,
                    //   ),
                    // ),
                  ),
                  validator: (value) {
                    return null;
                  },
                  style: $styles.text.h3,
                ),
              ),
              SizedBox(height: $styles.insets.offset),
              GestureDetector(
                onTap: () async {
                  _isLoading = true;
                  setState(() {});
                  final request =
                      await ImpulsePermissionHandler.checkStoragePermission();
                  if (!request) {
                    _hasAcceptedStoragePermission = false;
                    _isLoading = false;
                    setState(() {});
                    return;
                  } else {
                    _hasAcceptedStoragePermission = false;
                    setState(() {});
                    final selectedImage = images[currentIndex];
                    final user = User(
                      name: _controller.value.text.trim(),
                      id: const Uuid().v4(),
                      deviceName: Platform.operatingSystem,
                      deviceOsVersion: Platform.operatingSystemVersion,
                      displayImage: selectedImage.$2,
                    );
                    await Configurations.instance.saveUserInfo(user.toMap());
                    await Configurations.instance.loadAllInit();

                    ref
                        .read(profileImageProvider.notifier)
                        .onChanged(selectedImage.$2);
                    _isLoading = false;
                    setState(() {});
                    if (_isFirstRun) {
                      // ignore: use_build_context_synchronously
                      context.go(
                        isAndroid
                            ? ImpulseRouter.routes.home
                            : ImpulseRouter.routes.folder,
                      );
                    } else {
                      // ignore: use_build_context_synchronously
                      context.pop();
                    }
                  }
                },
                child: Container(
                  height: 50,
                  width: 300.scale,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular($styles.corners.md),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Save",
                            style: $styles.text.h3.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: $styles.insets.offset),
              if (!_hasAcceptedStoragePermission)
                Text(
                  "Permission is needed",
                  style: $styles.text.body
                      .copyWith(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ImageItemChild extends StatelessWidget {
  ImageItemChild({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.assetImages,
    this.child,
  });
  final int index;
  final int currentIndex;
  final List<(_ImageType, String)> assetImages;
  Widget? child;

  bool get isSelected => currentIndex == index;

  @override
  Widget build(BuildContext context) {
    //remove the body padding from the total width to get the accurate remaining width
    final maxSize =
        ((MediaQuery.of(context).size.width - $styles.insets.md * 2) / 100) *
            20;
    final minSize = (MediaQuery.of(context).size.width / 100) * 10;
    return Center(
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isSelected ? maxSize : minSize,
            width: isSelected ? maxSize : minSize,
            // curve: $styles.curves.defaultCurve,
            constraints: BoxConstraints(
              maxWidth: isSelected ? 150 : 100,
              maxHeight: isSelected ? double.infinity : 100,
            ),
            decoration: BoxDecoration(
              color: child != null
                  ? Colors.black.withOpacity(.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(300),
              image: index + 1 > assetImages.length
                  ? null
                  : DecorationImage(
                      image: _getImageProvider(),
                      fit: BoxFit.cover,
                    ),
            ),
            child: child,
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isSelected ? maxSize : minSize,
            width: isSelected ? maxSize : minSize,
            // curve: $styles.curves.defaultCurve,
            constraints: BoxConstraints(
              maxWidth: isSelected ? 150 : 100,
              maxHeight: isSelected ? double.infinity : 100,
            ),
            decoration: BoxDecoration(
              color: currentIndex == index
                  ? Colors.transparent
                  : Colors.black.withOpacity(.5),
              borderRadius: BorderRadius.circular(300),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider() {
    if (assetImages[index].$1.isFile) {
      return FileImage(
        File(assetImages[index].$2),
      );
    } else {
      return AssetImage(
        assetImages[index].$2,
      );
    }
  }
}
