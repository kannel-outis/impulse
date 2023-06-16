abstract interface class ServerManager<T> {
  //TODO: should change to sync function later
  Future<T> get hostInfo;
  List<String> getFiles();
  List<String> getPaths();
}
