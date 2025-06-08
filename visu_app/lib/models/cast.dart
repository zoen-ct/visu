class Cast {

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profilePath: json['profile_path'] ?? '',
    );
  }

  Cast({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });
  
  final int id;
  final String name;
  final String character;
  final String profilePath;
}