import '/visu.dart';

enum MediaType { movie, tv, person, unknown }

class SearchResult {
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    MediaType type;
    switch (json['media_type'] as String? ?? 'unknown') {
      case 'movie':
        type = MediaType.movie;
        break;
      case 'tv':
        type = MediaType.tv;
        break;
      case 'person':
        type = MediaType.person;
        break;
      default:
        type = MediaType.unknown;
        break;
    }

    String title;
    if (type == MediaType.movie) {
      title = json['title'] as String? ?? 'Sans titre';
    } else if (type == MediaType.tv) {
      title = json['name'] as String? ?? 'Sans titre';
    } else if (type == MediaType.person) {
      title = json['name'] as String? ?? 'Sans nom';
    } else {
      title =
          json['title'] as String? ?? json['name'] as String? ?? 'Sans titre';
    }

    String? releaseDate;
    if (type == MediaType.movie) {
      releaseDate = json['release_date'] as String?;
    } else if (type == MediaType.tv) {
      releaseDate = json['first_air_date'] as String?;
    }

    return SearchResult(
      id: json['id'] as int? ?? 0,
      title: title,
      posterPath:
          json['poster_path'] as String? ??
          json['profile_path'] as String? ??
          '',
      mediaType: type,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: releaseDate,
      overview: json['overview'] as String? ?? 'Aucune description disponible',
      seasonNumber: json['season_number'] as int?,
      episodeNumber: json['episode_number'] as int?,
    );
  }

  SearchResult({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.mediaType,
    required this.voteAverage,
    this.releaseDate,
    required this.overview,
    this.seasonNumber,
    this.episodeNumber,
  });

  final int id;
  final String title;
  final String posterPath;
  final MediaType mediaType;
  final double voteAverage;
  final String? releaseDate;
  final String overview;
  final int? seasonNumber;
  final int? episodeNumber;

  String getFormattedReleaseDate() {
    if (releaseDate == null || releaseDate!.isEmpty) {
      return 'Date inconnue';
    }

    try {
      final parts = releaseDate!.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return releaseDate!;
    } catch (e) {
      return 'Date inconnue';
    }
  }

  String getFullPosterPath() {
    if (posterPath.isEmpty) {
      return 'https://via.placeholder.com/500x750?text=No+Image';
    }
    // Construction directe de l'URL pour garantir que le format est correct
    final String cleanPath =
        posterPath.startsWith('/') ? posterPath : '/$posterPath';
    return 'https://image.tmdb.org/t/p/w500$cleanPath';
  }

  String getMediaTypeDisplay() {
    switch (mediaType) {
      case MediaType.movie:
        return 'Film';
      case MediaType.tv:
        return 'Série';
      case MediaType.person:
        return 'Personne';
      case MediaType.unknown:
        return 'Inconnu';
    }
  }

  String getYearFromReleaseDate() {
    if (releaseDate == null || releaseDate!.isEmpty) {
      return '';
    }

    try {
      return releaseDate!.substring(0, 4);
    } catch (e) {
      return '';
    }
  }
}
