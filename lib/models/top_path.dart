class TopPath {
  final String name;
  final String location;

  const TopPath({
    required this.location,
    required this.name,
  });

  String get locationDecode => Uri.decodeComponent(location);
}
