import 'dart:io';

abstract interface class Client {
  Future<List<String>> scan();
}
