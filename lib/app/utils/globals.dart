import 'dart:io';

import 'package:flutter/material.dart';
import 'package:impulse/app/utils/enums.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/views/home/components/custom_modal.dart';

import '../../impulse_scaffold.dart';
import '../styles/impulse_app_style.dart';
import 'generic_provider_ref.dart';

AppStyle get $styles => ImpulseScaffold.style;
TextStyle get bodyStyle => $styles.text.body;
bool get isAndroid => Platform.isAndroid;

void showModel(bool isHost, BuildContext context) {
  showModalBottomSheet(
    context: context,
    constraints: $styles.constraints.modalConstraints,
    builder: (context) {
      if (isHost) {
        return const CustomHostBottomModalSheet();
      }
      return const CustomClientBottomModalSheet();
    },
  );
}

Future<void> share(GenericProviderRef ref, [bool onConnection = false]) async {
  if (onConnection == true && ref.read(userTypeProvider) != UserType.host) {
    return;
  }

  // get the [ServerInfo] of the connected user whic contains their ip address and port
  final destination = ref.read(connectUserStateProvider);
  if (destination == null) return;
  final hostController = ref.read(senderProvider);

  /// set own destination (i.e our ip and port addresses) to the items that dont already have a destination
  /// specifically for items that were selected before connection
  /// This may be replaced by own id in the future instead of ip and port
  final files = ref.read(selectedItemsProvider);
  for (final item in files) {
    item.homeDestination ??= (
      ref.read(serverControllerProvider).ipAddress!,
      ref.read(serverControllerProvider).port!
    );
  }

  ///filter the selected items and seperate the once that are not duplicate and can be shared
  ///This is mostly to remove duplicates from the list of shared items
  ///These items are them converted to a map and sent to the receiver to initiate download.
  ref.read(shareableItemsProvider.notifier).addAllItems(files);
  final shareableFiles = ref
      .read(shareableItemsProvider.notifier)
      .filteredList
      .map((e) => e.toMap())
      .toList();
  // print(files);
  print(shareableFiles.length);

  // return;

  await hostController.shareDownloadableFiles(
      shareableFiles, (destination.ipAddress!, destination.port!));

  /// Selected items list is cleared and made ready for another bunch of items
  ref.read(selectedItemsProvider.notifier).clear();
}
