class Serie {
  // Factory method to create a series from JSON
  factory Serie.fromJson(Map<String, dynamic> json) {
    return Serie(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      rating: (json['rating'] as num).toDouble(),
      releaseDate: json['releaseDate'],
      description: json['description'],
      genres: List<String>.from(json['genres']),
    );
  }

  Serie({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.releaseDate,
    required this.description,
    required this.genres,
  });

  final int id;
  final String title;
  final String imageUrl;
  final double rating;
  final String releaseDate;
  final String description;
  final List<String> genres;
}
