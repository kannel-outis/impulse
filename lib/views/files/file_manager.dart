import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/file_manager/file_manager_controller.dart';

class FileManagerScreen extends ConsumerStatefulWidget {
  const FileManagerScreen({super.key});

  @override
  ConsumerState<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends ConsumerState<FileManagerScreen> {
  @override
  Widget build(BuildContext context) {
    final fileManagerController = ref.read(fileManagerProvider);
    return ListView.builder(
      itemCount: fileManagerController.goToPath().length,
      itemBuilder: (context, index) {
        final item = fileManagerController.goToPath()[index];
        return Container(
          height: 70,
          width: double.infinity,
          // color: Colors.grey.withOpacity(.5),
          margin: $styles.insets.sm.insetsBottom,
          child: Row(
            children: [
              Icon(
                ImpulseIcons.bxs_folder,
                size: 50.scale,
              ),
              const SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    child: Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                      style: $styles.text.body,
                    ),
                  ),
                  Text(
                    item.file.statSync().modified.toString(),
                    style: $styles.text.body,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
