abstract interface class ServerManager<T> {
  //TODO: should change to sync function later
  Future<T> get hostInfo;
  Future<T> get myServerInfo;
  List<String> getFiles();
  List<String> getPaths();

  //subject to removal later 
  dynamic handlePostResult(Map<String, dynamic> map);
}
