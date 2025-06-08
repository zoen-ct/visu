import '/visu.dart';

class TvShowDetails {

  factory TvShowDetails.fromJson(Map<String, dynamic> json) {
    final List<Genre> genresList = [];
    if (json['genres'] != null) {
      for (final genre in json['genres']) {
        genresList.add(Genre.fromJson(genre));
      }
    }

    final List<Season> seasonsList = [];
    if (json['seasons'] != null) {
      for (final season in json['seasons']) {
        seasonsList.add(Season.fromJson(season));
      }
    }

    final List<Creator> creatorsList = [];
    if (json['created_by'] != null) {
      for (final creator in json['created_by']) {
        creatorsList.add(Creator.fromJson(creator));
      }
    }

    final List<Cast> castList = [];
    if (json['credits'] != null && (json['credits'] as Map<String, dynamic>)['cast'] != null) {
      for (final actor in (json['credits'] as Map<String, dynamic>)['cast']) {
        castList.add(Cast.fromJson(actor));
      }
    }

    return TvShowDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      firstAirDate: json['first_air_date'] ?? '',
      lastAirDate: json['last_air_date'] ?? '',
      numberOfSeasons: json['number_of_seasons'] ?? 0,
      numberOfEpisodes: json['number_of_episodes'] ?? 0,
      status: json['status'] ?? '',
      genres: genresList,
      seasons: seasonsList,
      creators: creatorsList,
      cast: castList,
    );
  }

  TvShowDetails({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.firstAirDate,
    required this.lastAirDate,
    required this.numberOfSeasons,
    required this.numberOfEpisodes,
    required this.status,
    required this.genres,
    required this.seasons,
    required this.creators,
    required this.cast,
  });

  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final int voteCount;
  final String firstAirDate;
  final String lastAirDate;
  final int numberOfSeasons;
  final int numberOfEpisodes;
  final String status;
  final List<Genre> genres;
  final List<Season> seasons;
  final List<Creator> creators;
  final List<Cast> cast;
}