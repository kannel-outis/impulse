import 'dart:io';

abstract interface class Host {
  Future<void> createServer({InternetAddress? address, int? port});
}
