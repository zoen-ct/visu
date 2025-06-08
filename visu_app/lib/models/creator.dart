class Creator {

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePath: json['profile_path'] ?? '',
    );
  }

  Creator({required this.id, required this.name, required this.profilePath});

  final int id;
  final String name;
  final String profilePath;
}
