import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '/visu.dart';

class TMDbConfig {
  static const String apiKey = ApiConfig.tmdbApiKey;
  static const String baseUrl = ApiConfig.tmdbBaseUrl;
  static const String imageBaseUrl = ApiConfig.tmdbImageBaseUrl;

  static const String posterSize = ApiConfig.posterSize;
  static const String backdropSize = ApiConfig.backdropSize;
  static const String profileSize = ApiConfig.profileSize;

  // Endpoints
  static String getTvShowDetails(int id) => '/tv/$id';
  static String getTvShowSeasons(int id, int seasonNumber) =>
      '/tv/$id/season/$seasonNumber';
}

class TMDbService {
  TMDbService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final String _baseUrl = ApiConfig.tmdbBaseUrl;
  final String _apiKey = ApiConfig.tmdbApiKey;
  final String _language = 'fr-FR';

  String get imageBaseUrl => ApiConfig.tmdbImageBaseUrl;

  Future<TvShowDetails> getTvShowDetails(int id) async {
    try {
      final url =
          '$_baseUrl/tv/$id?api_key=$_apiKey&language=$_language&append_to_response=credits';

      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TvShowDetails.fromJson(data);
      } else {
        throw Exception(
          'Échec de chargement des détails de la série: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des détails de la série: $e',
      );
    }
  }

  Future<Map<String, dynamic>> getSeasonDetails(
    int showId,
    int seasonNumber, {
    String language = 'fr-FR',
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '${TMDbConfig.baseUrl}${TMDbConfig.getTvShowSeasons(showId, seasonNumber)}?api_key=${TMDbConfig.apiKey}&language=$language',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Échec du chargement des détails de la saison');
      }
    } catch (e) {
      throw Exception('Erreur de connexion à TMDb');
    }
  }

  String getImageUrl(String path, {String size = TMDbConfig.posterSize}) {
    if (path.isEmpty) return '';
    return '$imageBaseUrl$size$path';
  }

  Future<bool> addToFavorites(int serieId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> removeFromFavorites(int serieId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real application, this method would send a request to the TMDb API
    // to remove the series from the user's favorites
    return true;
  }

  Future<bool> isFavorite(int serieId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real application, this method would check if the series
    // is in the user's favorites
    return serieId % 2 == 0; // Simulation: series with even IDs are favorites
  }

  Future<bool> addToWatchlist(int serieId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real application, this method would send a request to the TMDb API
    // to add the series to the user's watchlist
    return true;
  }

  Future<bool> removeFromWatchlist(int serieId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real application, this method would send a request to the TMDb API
    // to remove the series from the user's watchlist
    return true;
  }

  Future<bool> isInWatchlist(int serieId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real application, this method would check if the series
    // is in the user's watchlist
    return serieId % 3 == 0; // Simulation: series with IDs divisible by 3 are in watchlist
  }

  Future<List<Serie>> getPopularSeries({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tv/popular?api_key=$_apiKey&language=fr-FR&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((serie) => Serie.fromSearchJson(serie)).toList();
    } else {
      throw Exception('Échec de chargement des séries populaires');
    }
  }

  Future<List<Serie>> searchSeries(String query, {int page = 1}) async {
    if (query.isEmpty) {
      return [];
    }

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/search/tv?api_key=$_apiKey&language=fr-FR&query=${Uri.encodeComponent(query)}&page=$page',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((serie) => Serie.fromSearchJson(serie)).toList();
    } else {
      throw Exception('Échec de la recherche de séries');
    }
  }

  Future<List<Serie>> getTrendingSeries({String timeWindow = 'week'}) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/trending/tv/$timeWindow?api_key=$_apiKey&language=fr-FR',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((serie) => Serie.fromSearchJson(serie)).toList();
    } else {
      throw Exception('Échec de chargement des séries tendances');
    }
  }

  Future<Episode> getEpisodeDetails(
    int serieId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '$_baseUrl/tv/$serieId/season/$seasonNumber/episode/$episodeNumber?api_key=$_apiKey&language=$_language',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Episode.fromJson(data, serieId: serieId, seasonId: seasonNumber);
      } else {
        throw Exception('Échec du chargement des détails de l\'épisode');
      }
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des détails de l\'épisode: $e',
      );
    }
  }

  Future<bool> markEpisodeAsWatched(
    int episodeId, {
    bool watched = true,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();
      final List<String> watchedEpisodes =
          prefs.getStringList('watched_episodes') ?? [];

      if (watched) {
        if (!watchedEpisodes.contains(episodeId.toString())) {
          watchedEpisodes.add(episodeId.toString());
        }
      } else {
        watchedEpisodes.remove(episodeId.toString());
      }

      await prefs.setStringList('watched_episodes', watchedEpisodes);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isEpisodeWatched(int episodeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> watchedEpisodes =
          prefs.getStringList('watched_episodes') ?? [];

      return watchedEpisodes.contains(episodeId.toString());
    } catch (e) {
      return false;
    }
  }

  Future<List<SearchResult>> searchMulti(String query, {int page = 1}) async {
    if (query.isEmpty) {
      return [];
    }

    final response = await _client.get(
      Uri.parse(
        '$_baseUrl/search/multi?api_key=$_apiKey&language=$_language&query=${Uri.encodeComponent(query)}&page=$page',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results
          .map((item) => SearchResult.fromJson(item))
          .where((result) => result.mediaType != MediaType.person)
          .toList();
    } else {
      throw Exception('Échec de la recherche multi-type');
    }
  }

  Future<SearchResult> getMediaDetails(
    int id, {
    MediaType mediaType = MediaType.unknown,
  }) async {
    try {
      String endpoint;

      if (mediaType == MediaType.unknown) {
        mediaType = MediaType.tv;
      }

      switch (mediaType) {
        case MediaType.movie:
          endpoint = 'movie';
          break;
        case MediaType.tv:
          endpoint = 'tv';
          break;
        default:
          endpoint = 'tv';
      }

      final response = await _client.get(
        Uri.parse(
          '$_baseUrl/$endpoint/$id?api_key=$_apiKey&language=$_language',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        data['media_type'] = endpoint;

        return SearchResult.fromJson(data);
      } else {
        throw Exception('Échec de la récupération des détails du média');
      }
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des détails du média: $e',
      );
    }
  }
}
