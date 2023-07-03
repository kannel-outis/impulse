
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
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

  bool _isWaitingForReceiver = false;

  bool _shouldShowTopStack = false;

  Future<void> getAllApplications() async {
    if (!isAndroid) return;
    _isGettingAllApplications = true;
    notifyListeners();
    _applications = await utils.getInstalledApplication();
    // _applications.sort(
    //     (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    _isGettingAllApplications = false;
    notifyListeners();
  }

  // set isWaitingForReceiver(bool isWaiting) {
  //   _isWaitingForReceiver = isWaiting;
  //   notifyListeners();
  // }

  set shouldShowTopStack(bool topStack) {
    _shouldShowTopStack = topStack;
    notifyListeners();
  }

  ////
  bool get isGettingAllApplications => _isGettingAllApplications;
  bool get shouldShowTopStack => _shouldShowTopStack;
  bool get isWaitingForReceiver => _isWaitingForReceiver;
}
