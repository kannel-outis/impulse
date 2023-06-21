import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:impulse/app/utils/globals.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Text(
              "data this isthe gate this is the gate thsi is the gateh",
              style: $styles.text.body,
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final dir = Directory("/system/fonts");
            if (dir.existsSync()) {
              final list = dir.listSync();
              for (final l in list) {
                log(l.toString());
              }
            }
          },
        ),
      ),
    );
  }
}
