import 'dart:io';

import 'package:dartz/dartz.dart' as d;
import 'package:flutter/material.dart';
import 'package:impulse/controllers/server_controller.dart';
import 'package:impulse/services/client/client.dart';
import 'package:impulse/services/client/receiver_client.dart';
import 'package:impulse/services/host/host.dart';
import 'package:impulse/services/host/sender_host.dart';
import 'package:impulse/services/host/server.dart';

import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  late Client receiver;
  late Host sender;
  User? _user;
  @override
  void initState() {
    super.initState();
    receiver = Receiver();
    sender = Sender(
      gateWay: MyHttpServer(
        serverManager: ServerController(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'You have pushed the button this many times: ${_user?.deviceName}',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            GestureDetector(
              onTap: () async {
                await receiver.scan().then((value) async {
                  final response = await receiver.establishConnectionToHost();
                  if (response is d.Right) {
                    final result = response.map(
                        (r) => User.fromMap(r["user"] as Map<String, dynamic>));
                    _user = (result as d.Right).value as User;
                    setState(() {});
                  }
                });
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(100),
                  image: _user == null
                      ? null
                      : DecorationImage(
                          image: MemoryImage(_user!.displayImage),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await sender.createServer();
          // sender.scan();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
