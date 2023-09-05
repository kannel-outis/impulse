// ignore_for_file: unnecessary_getters_setters

import 'package:impulse/models/models.dart';

class Session {
  final String id;
  final List<User> usersOnSession;
  Session({
    required this.id,
    required this.usersOnSession,
  });

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map["id"],
      usersOnSession: [
        for (final userMap in map["users"]) User.fromMap(userMap)
      ],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "users": [
        for (final user in usersOnSession) user.toMap(),
      ]
    };
  }
}
