import 'dart:developer';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/services/services.dart';
import 'package:impulse/views/home/components/custom_modal.dart';
import 'package:impulse/views/shared/continue_dialog.dart';

import '../../impulse_scaffold.dart';

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
    await HiveManagerImpl.instance
        .saveItem(item, ref.read(currentSessionStateProvider)!.id);
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
  // print(shareableFiles.length);

  // return;

  await hostController.shareDownloadableFiles(
      shareableFiles, (destination.ipAddress!, destination.port!));

  /// Selected items list is cleared and made ready for another bunch of items
  ref.read(selectedItemsProvider.notifier).clear();
}

Future<void> disconnect(GenericProviderRef ref) async {
  //Set prev session and save to hive box
  // ref.read(connectedUserPreviousSessionStateProvider)?.$2
  //   ?..previousSessionId = ref.read(currentSessionStateProvider)?.id
  //   ..previousSessionReceivable = ref
  //       .read(receivableListItems)
  //       .where((element) => !element.state.isCompleted)
  //       .map((e) => e.toHiveItem(ref.read(currentSessionStateProvider)!.id))
  //       .toList()
  //   ..previousSessionShareable = ref
  //       .read(shareableItemsProvider)
  //       .where((element) => !element.state.isCompleted)
  //       .map((e) => e.toHiveItem(ref.read(currentSessionStateProvider)!.id))
  //       .toList()
  //   ..save();
  //is user was a client, close server
  if (ref.read(userTypeProvider) != UserType.host) {
    ref.read(receiverProvider).disconnect();
  }
  //set connecteduser to null
  ref
      .read(connectUserStateProvider.notifier)
      .setUserState(null, disconnected: true);

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

  //clear all lists
  ref.read(shareableItemsProvider.notifier).clear();
  ref.read(selectedItemsProvider.notifier).clear();
  ref.read(receivableListItems.notifier).clear();
  ref.read(uploadManagerProvider.notifier).clear();
  ref.read(connectedUserPreviousSessionStateProvider.notifier).clear();
  //remove all server list for shareable items
  // ref.read(serverControllerProvider).setSelectedItems([]);
}

void checkPrevDownloadListener(ConnectionState? previous, ConnectionState next,
    GenericProviderRef ref, BuildContext context) {
  if (next.isConnected) {
    final connectedUserSessions =
        ref.read(connectedUserPreviousSessionStateProvider)!;
    for (var element
        in connectedUserSessions.prevSession.previousSessionReceivable) {
      print("$element ::::::::::::::");
    }
    final inCompleteDownloads = connectedUserSessions
        .prevSession.previousSessionReceivable
        .map((e) => HiveManagerImpl.instance.getReceiveableItemWithKey(e))
        .toList()
        .where((e) => e != null && !e.state.isCompleted && !e.state.isCanceled)
        .toList();
    if (inCompleteDownloads.isNotEmpty) {
      for (var s in inCompleteDownloads) {
        log(s!.name);
      }
      showDialog(
        context: context,
        useRootNavigator: true,
        builder: (context) {
          return const ContinueDownloadDialog();
        },
      );
    } else {
      ref
          .read(connectedUserPreviousSessionStateProvider.notifier)
          .hasSetNewPrev();
    }
  }
}
