import 'dart:async';

import 'package:flutter/material.dart' hide ConnectionState, Path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse/views/shared/padded_body.dart';

import 'widgets/network_file_manager_tile.dart';

class NetworkFileManagerScreen extends ConsumerStatefulWidget {
  final String? networkPath;
  final Path? path;
  const NetworkFileManagerScreen({super.key, this.networkPath, this.path});

  @override
  ConsumerState<NetworkFileManagerScreen> createState() =>
      _FileManagerScreenState();
}

class _FileManagerScreenState extends ConsumerState<NetworkFileManagerScreen>
    with AutomaticKeepAliveClientMixin {
  Future<List<NetworkImpulseFileEntity>> _init_() async {
    final serverInfo = ref.read(connectUserStateProvider);
    return await ref.read(receiverProvider).getNetworkFiles(
      destination: (serverInfo!.ipAddress!, serverInfo.port!),
      path: widget.networkPath,
    );
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: () async {
        final pathProvider = ref.watch(pathController.notifier);
        if (widget.path != null) {
          pathProvider.pop();
        }
        return true;
      },
      child: FutureBuilder<List<NetworkImpulseFileEntity>>(
        future: _init_(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Icon(
                Icons.inventory_2,
                size: $styles.sizes.prefixIconSize * 4,
                color: Colors.red,
              ),
            );
          }
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
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];
                        return NetworkFileManagerTile(
                          item: item,
                        );
                      },
                    ),
                  ),
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
}
