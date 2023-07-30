// ignore_for_file: unnecessary_getters_setters

import 'package:impulse/models/models.dart';

class Session {
  final String id;
  final DateTime sessionCreated;
  final List<User> usersOnSession;
  Session({
    required this.id,
    required this.usersOnSession,
    required this.sessionCreated,
  });

  DateTime? _sessionActivated = null;

  DateTime? get sessionActivated => _sessionActivated;

  set sessionActivated(DateTime? time) {
    _sessionActivated = time;
  }
}
