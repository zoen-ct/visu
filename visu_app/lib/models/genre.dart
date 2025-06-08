class Genre {

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Genre({required this.id, required this.name});
  final int id;
  final String name;
}