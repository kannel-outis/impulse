import 'dart:io';

import 'package:dartz/dartz.dart' as d;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/impulse_exception.dart';
import 'package:impulse/controllers/server_controller.dart';
import 'package:impulse/models/server_info.dart';
import 'package:impulse/services/client/client.dart';
import 'package:impulse/services/client/receiver_client.dart';
import 'package:impulse/services/host/host.dart';
import 'package:impulse/services/host/sender_host.dart';
import 'package:impulse/services/shared/server.dart';
import 'package:impulse/services/utils/constants.dart';

import 'models/user.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  int _counter = 0;

  late Client receiver;
  late Host sender;
  ServerInfo? _secondDeviceServerInfo;
  late final ServerController serverController;
  @override
  void initState() {
    super.initState();
    serverController = ref.read(serverControllerProvider);

    ///this is just for testing, [Receiver] object by deafult may not implement [Host]
    ///after assumption of its initial role as a client
    receiver = Receiver(
      gateWay: MyHttpServer(
        serverManager: serverController,
      ),
    );
    sender = Sender(
      gateWay: MyHttpServer(
        serverManager: serverController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(serverControllerProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Connected to: ${provider.serverInfo?.ipAddress ?? _secondDeviceServerInfo?.ipAddress}, on port: ${provider.serverInfo?.port ?? _secondDeviceServerInfo?.port}',
            ),
            Text(
              "Running on OS: ${provider.serverInfo?.user.deviceName ?? _secondDeviceServerInfo?.user.deviceName}",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            GestureDetector(
              onTap: () async {
                ///each device assume a particular role of [Client] and [Host] on first connection before deciding
                ///whether they would want the roles to go both ways.
                ///client scans for available host.
                await receiver.scan().then((value) async {
                  /// if any device is found, then definitely the default port is occupied,
                  /// use the second port to create own server

                  final response = await receiver.establishConnectionToHost();
                  if (response is d.Right) {
                    final result = response.map((r) => ServerInfo.fromMap(
                        r["hostServerInfo"] as Map<String, dynamic>));
                    _secondDeviceServerInfo =
                        (result as d.Right).value as ServerInfo;
                    setState(() {});
                  } else {
                    final result = (response as d.Left).value as AppException;
                    print(result.message);
                  }

                  ///after the client establishes a connection with the host and receives the host server information
                  ///create client server using another port because now we already know that the first port is occupied.
                  ///then after that, the client makes a post request to the host server to let them know about their new
                  ///created server information including theri new port.
                  await (receiver as Host)
                      .createServer(port: Constants.DEFAULT_PORT_2)
                      .then(
                    (value) async {
                      ///make post request to the host to update it about our new server on the client side
                      if (value is d.Right) {
                        final (ip, port) =
                            ((value as d.Right).value as (String, int));
                        final myInfo = await serverController.myServerInfo;
                        myInfo.port = port;
                        myInfo.ipAddress = ip;
                        await receiver.makePostRequest(
                          body: myInfo.toMap(),
                          address: _secondDeviceServerInfo!.ipAddress,
                          port: _secondDeviceServerInfo!.port,
                        );
                        // await Future.delayed(const Duration(seconds: 5));
                      }
                    },
                  );
                });
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(100),
                  image: _secondDeviceServerInfo == null &&
                          provider.serverInfo?.user.displayImage == null
                      ? null
                      : DecorationImage(
                          image: MemoryImage(
                              provider.serverInfo?.user.displayImage ??
                                  _secondDeviceServerInfo!.user.displayImage),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ///host creates server
          await sender.createServer();
          // sender.scan();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
