import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';

mixin SharingIntentListener<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedFile>? list;

  @mustCallSuper
  @override
  void initState() {
    super.initState();
    if (isAndroid) {
      final mediaStream = FlutterSharingIntent.instance.getMediaStream();
      final mediaInitial = FlutterSharingIntent.instance.getInitialSharing();
      _intentDataStreamSubscription = mediaStream.listen(
        _listener,
        onError: (err) {
          log(err.toString());
        },
      );

      mediaInitial.then(_listener);
    }
  }

  void _listener(List<SharedFile> sharedFiles) async {
    if (sharedFiles.isNotEmpty) {
      for (var sharedFile in sharedFiles) {
        if (sharedFile.value != null) {
          log("${sharedFile.value!}::::::::::::");

          ref
              .read(selectedItemsProvider.notifier)
              .addSelected(path: sharedFile.value);
        }
      }
      if (ref.read(connectionStateProvider).isConnected) {
        final genericRef = GenericProviderRef<WidgetRef>(ref);

        await share(genericRef);
      } else {
        showModel(true, context);
      }
      FlutterSharingIntent.instance.reset();
    }
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }
}
