import 'dart:io';

import 'package:flutter/material.dart';

import '../../impulse_scaffold.dart';
import '../styles/impulse_app_style.dart';

AppStyle get $styles => ImpulseScaffold.style;
TextStyle get bodyStyle => $styles.text.body;
bool get isAndroid => Platform.isAndroid;
