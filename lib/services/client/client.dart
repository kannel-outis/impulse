abstract interface class Client {
  Future<List<String>> scan();
  Future<void> establishConnectionToHost({String? address, int? port});
}
