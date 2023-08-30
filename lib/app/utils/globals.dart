import 'dart:io';

import 'package:flutter/material.dart' hide ConnectionState;
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
  if (files.isEmpty) return;
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
  ref.read(uploadManagerProvider.notifier).addToQueue(files);
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

Future<void> disconnect(GenericProviderRef ref) async {
  //is user was a client, close server
  if (ref.read(userTypeProvider) != UserType.host) {
    ref.read(receiverProvider).disconnect();
  }
  //set connecteduser to null
  ref
      .read(connectUserStateProvider.notifier)
      .setUserState(null, disconnected: true);
  //clear all lists
  ref.read(shareableItemsProvider.notifier).clear();
  ref.read(selectedItemsProvider.notifier).clear();
  ref.read(receivableListItems.notifier).clear();
  ref.read(uploadManagerProvider.notifier).clear();

  // set connection state to disconneted
  ref
      .read(connectionStateProvider.notifier)
      .setState(ConnectionState.disconnected);

  //set port and ip to null
  if (ref.read(userTypeProvider) == UserType.client) {
    ref.read(serverControllerProvider)
      ..port = null
      ..ipAddress = null;
  }
  //remove all server list for shareable items
  // ref.read(serverControllerProvider).setSelectedItems([]);
}
