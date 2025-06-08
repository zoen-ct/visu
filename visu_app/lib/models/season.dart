class Season {

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      posterPath: json['poster_path'] ?? '',
      seasonNumber: json['season_number'] ?? 0,
      episodeCount: json['episode_count'] ?? 0,
      airDate: json['air_date'] ?? '',
      overview: json['overview'] ?? '',
    );
  }

  Season({
    required this.id,
    required this.name,
    required this.posterPath,
    required this.seasonNumber,
    required this.episodeCount,
    required this.airDate,
    required this.overview,
  });

  final int id;
  final String name;
  final String posterPath;
  final int seasonNumber;
  final int episodeCount;
  final String airDate;
  final String overview;
}