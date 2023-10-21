import 'package:flutter/material.dart' hide Path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse/services/services.dart';
import 'package:impulse/views/shared/hover.dart';
import 'package:impulse_utils/impulse_utils.dart';
import 'package:uuid/uuid.dart';

class NetworkFileManagerTile extends ConsumerStatefulWidget {
  final NetworkImpulseFileEntity item;
  const NetworkFileManagerTile({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<NetworkFileManagerTile> createState() =>
      _NetworkFileManagerTileState();
}

class _NetworkFileManagerTileState
    extends ConsumerState<NetworkFileManagerTile> {
  bool _onHover = false;

  ImpulseFileStorage get asStorageFile => widget.item as ImpulseFileStorage;

  double get leftItemPadding => 15;
  @override
  Widget build(BuildContext context) {
    return Hover(
      onHover: (hover) {
        _onHover = hover;
        setState(() {});
      },
      cursor: !widget.item.isFolder
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.item.isFolder
            ? () {
                context.pushNamed(
                  "NetworkfilesPath",
                  pathParameters: {
                    "path": widget.item.path,
                    "username": widget.item.serverInfo.user.name,
                  },
                  extra: widget.item.name,
                );
                // }
              }
            : null,
        child: Stack(
          children: [
            Container(
              height: 70,
              width: double.infinity,
              color:
                  _onHover ? Theme.of(context).hoverColor : Colors.transparent,
              margin: $styles.insets.sm.insetsBottom,
              child: Row(
                children: [
                  FilePlaceHolder(
                    name: widget.item.name,
                    isFolder: widget.item.isFolder,
                  ),
                  SizedBox(width: leftItemPadding),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(builder: (context, constraints) {
                          return SizedBox(
                            // width: _itemTileWidth(padding: leftItemPadding * 4),
                            width: constraints.maxWidth - (isAndroid ? 70 : 60),
                            child: Text(
                              widget.item.name,
                              overflow: TextOverflow.ellipsis,
                              style: $styles.text.body,
                            ),
                          );
                        }),
                        Text(
                          widget.item.isFolder
                              ? widget.item.modified
                                  .toString()
                                  .cutTimeDateString
                              : widget.item.sizeToString,
                          style: $styles.text.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_onHover && !widget.item.isFolder ||
                !widget.item.isFolder && isAndroid)
              Positioned(
                right: 20,
                top: (70 / 2) - (30 / 2),
                child: GestureDetector(
                  onTap: () async {
                    final receiverController = ref.read(receiverProvider);
                    final connectedUser = ref.read(connectUserStateProvider);
                    final serverController = ref.read(serverControllerProvider);

                    ///This Network item is converted to a map so it can be sent to the files home server
                    ///The home server is the server that hosts/owns this file.
                    ///All the server specific info here is directed to the home server and not whoever is making this request
                    ///because its just a host file access from the client
                    final shareableItemMap = {
                      "path": widget.item.path,
                      "fileType": widget.item.path.getFileType.type,
                      "fileSize": widget.item.size,
                      "fileId": const Uuid().v4(),
                      "senderId": widget.item.serverInfo.user.id,
                      "altName": widget.item.name,
                      // "ip": widget.item.serverInfo.ipAddress,
                      // "port": widget.item.serverInfo.port,
                      "homeDestination": {
                        "ip": widget.item.serverInfo.ipAddress,
                        "port": widget.item.serverInfo.port,
                      }
                    };

                    ///This map is then sent to the home server basically telling that server
                    ///"i want this item too, add it to the list of items that should be shared with me"
                    await receiverController.addMoreShareablesOnHostServer(
                      shareableItemMap: shareableItemMap,
                      destination: connectedUser!,
                    );

                    ///Becuase we dont want to just circle back and go through the original process of sending and receiving items,
                    ///making unnecessary requests,
                    ///we just want the home server to be aware of this item and do the needed (which will not include sending it back to us, thus making that circle),
                    ///we try to imitate the original behaviour (how it would behave if it were the home server sending it itself)
                    ///by just adding to the receivablesItemsContorller that directly gets items from the server.
                    serverController.receivablesStreamController.add(
                        await ShareableItem.fromMap(shareableItemMap).toMap());
                  },
                  child: SizedBox(
                    width: isAndroid ? 40 : 30,
                    height: isAndroid ? 40 : 30,
                    child: Icon(
                      ImpulseIcons.receive,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
