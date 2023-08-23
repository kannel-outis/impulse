import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse/services/services.dart';

class GHelper {
  const GHelper._();

  static Future<List<NetworkImpulseFileEntity>?> getNetworkFiles(
      {String? path,
      required Client client,
      required (String, int) destination}) async {
    final result = <NetworkImpulseFileEntity>[];

    final response = await client.getNetworkFiles(path ?? "root", destination);
    if (response is Left) {
      return null;
    } else {
      final entities = (response as Right).value as List<Map<String, dynamic>>;
      log(entities.toString());
      for (var entity in entities) {
        result.add(NetworkImpulseFileEntity.fromMap(entity));
      }
    }
    return result;
  }
}
