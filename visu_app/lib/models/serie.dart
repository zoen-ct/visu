class Serie {
  factory Serie.fromSearchJson(Map<String, dynamic> json) {
    return Serie(
      id: json['id'] as int,
      title: json['name'] as String,
      imageUrl:
          json['poster_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
              : 'https://via.placeholder.com/500x750?text=No+Image',
      rating: (json['vote_average'] as num).toDouble(),
      releaseDate: json['first_air_date'] as String? ?? 'Date inconnue',
      description:
          json['overview'] as String? ?? 'Aucune description disponible',
      genres:
          [],
    );
  }

  // Convert a JSON object to a Serie object
  factory Serie.fromJson(Map<String, dynamic> json) {
    return Serie(
      id: json['id'] as int,
      title: json['name'] as String,
      imageUrl:
          json['poster_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
              : 'https://via.placeholder.com/500x750?text=No+Image',
      rating: (json['vote_average'] as num).toDouble(),
      releaseDate: json['first_air_date'] as String? ?? 'Date inconnue',
      description:
          json['overview'] as String? ?? 'Aucune description disponible',
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((genre) => (genre as Map<String, dynamic>)['name'] as String)
              .toList() ??
          [],
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
    this.isFavorite = false,
    this.watchLater = false,
  });

  final int id;
  final String title;
  final String imageUrl;
  final double rating;
  final String releaseDate;
  final String description;
  final List<String> genres;
  bool isFavorite;
  bool watchLater;
}
