class Episode {

  factory Episode.fromJson(
    Map<String, dynamic> json, {
    required int serieId,
    required int seasonId,
  }) {
    return Episode(
      id: json['id'],
      serieId: serieId,
      seasonId: seasonId,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      stillPath: json['still_path'] ?? '',
      episodeNumber: json['episode_number'] ?? 0,
      airDate:
          json['air_date'] != null && (json['air_date'] as String).isNotEmpty
              ? DateTime.parse(json['air_date'] as String)
              : DateTime.now(),
      voteAverage: (json['vote_average'] != null ? (json['vote_average'] as num).toDouble() : 0.0),
      runtime: json['runtime'] ?? 0,
      watched: false, 
    );
  }

  Episode({
    required this.id,
    required this.seasonId,
    required this.serieId,
    required this.name,
    required this.overview,
    required this.stillPath,
    required this.episodeNumber,
    required this.airDate,
    required this.voteAverage,
    required this.runtime,
    this.watched = false,
  });

  final int id;
  final int seasonId;
  final int serieId;
  final String name;
  final String overview;
  final String stillPath;
  final int episodeNumber;
  final DateTime airDate;
  final double voteAverage;
  final int runtime;
  bool watched;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serie_id': serieId,
      'season_id': seasonId,
      'name': name,
      'overview': overview,
      'still_path': stillPath,
      'episode_number': episodeNumber,
      'air_date': airDate.toIso8601String(),
      'vote_average': voteAverage,
      'runtime': runtime,
      'watched': watched,
    };
  }
}
