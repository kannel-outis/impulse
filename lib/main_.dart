import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/controllers/shared/client_controller.dart';
import 'package:impulse/controllers/shared/host_controller.dart';
import 'package:impulse/controllers/shared/server_controller.dart';

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
      home: const TestingHome(),
    );
  }
}

class TestingHome extends ConsumerStatefulWidget {
  const TestingHome({super.key});

  @override
  ConsumerState<TestingHome> createState() => _TestingHomeState();
}

class _TestingHomeState extends ConsumerState<TestingHome> {
  String text = "";
  bool isHost = false;
  bool isClient = false;

  void showSnack(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? "Something Went wrong"),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<bool> _scan({int? count}) async {
    Completer<bool> completer = Completer<bool>();
    Timer.periodic(
      const Duration(seconds: 5),
      (tick) async {
        // if (ref.read(clientProvider).availableHostServers.isNotEmpty) {
        //   completer.complete(true);
        //   tick.cancel();
        // }

        await ref.read(clientProvider).getAvailableUsers();
        print(tick.tick);

        if (tick.tick == (count ?? 3)) {
          tick.cancel();
          if (ref.read(clientProvider).availableHostServers.isNotEmpty) {
            completer.complete(true);
          } else {
            completer.complete(false);
          }
        }
      },
    );
    return await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final receiverController = ref.watch(clientProvider);
    final sendController = ref.watch(hostProvider);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final s in receiverController.availableHostServers)
            InkWell(
              onTap: () async {
                receiverController.selectHost(s);
                final d = await receiverController.createServerAndNotifyHost();
                if (d != null) {
                  showSnack(d.message);
                } else {
                  text =
                      "Connected to: ${receiverController.selectedHost!.ipAddress!}";
                  isClient = true;
                  setState(() {});
                }
              },
              child: Container(
                height: 100,
                width: 100,
                child: Image.memory(s.user.displayImage),
              ),
            ),
          if (sendController.myServer.clientServerInfo != null)
            Container(
              height: 100,
              width: 100,
              child: Image.memory(ref
                  .watch(serverControllerProvider)
                  .clientServerInfo!
                  .user
                  .displayImage),
            ),
          Text(sendController.myServer.clientServerInfo == null
              ? text
              : "Connected to : ${ref.watch(serverControllerProvider).clientServerInfo!.ipAddress!}"),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MyButton(
                onTap: () async {
                  final s = await sendController.createServer();
                  if (s != null) {
                    showSnack(s.message);
                  } else {
                    text = "Waiting for receiver...";
                    isHost = true;
                    setState(() {});
                  }
                },
                label: "Send",
                icon: Icons.upload,
                disable: isClient,
              ),
              MyButton(
                onTap: () async {
                  isClient = true;
                  text = "Scanning ....";
                  setState(() {});

                  final b = await _scan(count: 10);
                  if (b == false) {
                    showSnack("No Hosts Found");
                    isClient = false;
                    text = "";
                    setState(() {});
                  } else {
                    text = "";
                    setState(() {});
                    showSnack(
                        "${receiverController.availableHostServers.length}: Found");
                  }
                },
                disable: isHost,
                label: "Receive",
                icon: Icons.download,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String label;
  final bool disable;
  const MyButton({
    super.key,
    this.onTap,
    required this.icon,
    required this.label,
    this.disable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: disable ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: disable
                  ? Theme.of(context).buttonTheme.colorScheme!.secondary
                  : Theme.of(context).buttonTheme.colorScheme!.primary,
            ),
            child: Center(
              child: Icon(
                icon,
                color: disable ? Colors.black.withOpacity(.6) : Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: disable ? Colors.white.withOpacity(.3) : Colors.white,
          ),
        )
      ],
    );
  }
}
