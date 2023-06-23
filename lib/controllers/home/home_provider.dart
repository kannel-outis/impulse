import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse_utils/impulse_utils.dart';

final homeProvider = ChangeNotifierProvider<HomeController>((ref) {
  return HomeController(ImpulseUtils());
});

class HomeController extends ChangeNotifier {
  final ImpulseUtils utils;

  HomeController(this.utils);

  List<Application> _applications = [];
  List<Application> get applications {
    _applications.sort(
        (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    return _applications;
  }

  bool _isGettingAllApplications = false;
  bool get isGettingAllApplications => _isGettingAllApplications;

  Future<void> getAllApplications() async {
    if (!Platform.isAndroid) return;
    _isGettingAllApplications = true;
    notifyListeners();
    _applications = await utils.getInstalledApplication();
    // _applications.sort(
    //     (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    _isGettingAllApplications = false;
    notifyListeners();
  }
}
