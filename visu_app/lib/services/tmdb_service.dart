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
  static String getMovieDetails(int id) => '/movie/$id';
  static String getMovieCredits(int id) => '/movie/$id/credits';
  static String getSimilarMovies(int id) => '/movie/$id/similar';
}

class TMDbService {
  TMDbService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final String _baseUrl = ApiConfig.tmdbBaseUrl;
  final String _apiKey = ApiConfig.tmdbApiKey;
  final String _language = 'fr-FR';

  String get imageBaseUrl => ApiConfig.tmdbImageBaseUrl;

  // ===== SÉRIES TV =====

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

  Future<List<Serie>> getPopularSeries({int page = 1}) async {
    final response = await _client.get(
      Uri.parse(
        '$_baseUrl/tv/popular?api_key=$_apiKey&language=$_language&page=$page',
      ),
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

    final response = await _client.get(
      Uri.parse(
        '$_baseUrl/search/tv?api_key=$_apiKey&language=$_language&query=${Uri.encodeComponent(query)}&page=$page',
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
    final response = await _client.get(
      Uri.parse(
        '$_baseUrl/trending/tv/$timeWindow?api_key=$_apiKey&language=$_language',
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

  Future<List<Serie>> getSimilarSeries(int serieId, {int page = 1}) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '$_baseUrl/tv/$serieId/similar?api_key=$_apiKey&language=$_language&page=$page',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return results.map((serie) => Serie.fromSearchJson(serie)).toList();
      } else {
        throw Exception('Échec de la récupération des séries similaires');
      }
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des séries similaires: $e',
      );
    }
  }

  // ===== FILMS =====

  Future<Map<String, dynamic>> getMovieDetails(int id) async {
    try {
      final url =
          '$_baseUrl/movie/$id?api_key=$_apiKey&language=$_language&append_to_response=credits';

      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
          'Échec de chargement des détails du film: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des détails du film: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '$_baseUrl/movie/popular?api_key=$_apiKey&language=$_language&page=$page',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return results.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Échec de chargement des films populaires');
      }
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des films populaires: $e',
      );
    }
  }

  Future<List<Map<String, dynamic>>> searchMovies(
    String query, {
    int page = 1,
  }) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final response = await _client.get(
        Uri.parse(
          '$_baseUrl/search/movie?api_key=$_apiKey&language=$_language&query=${Uri.encodeComponent(query)}&page=$page',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return results.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Échec de la recherche de films');
      }
    } catch (e) {
      throw Exception('Erreur lors de la recherche de films: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingMovies({
    String timeWindow = 'week',
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '$_baseUrl/trending/movie/$timeWindow?api_key=$_apiKey&language=$_language',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return results.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Échec de chargement des films tendances');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des films tendances: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSimilarMovies(
    int movieId, {
    int page = 1,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '$_baseUrl/movie/$movieId/similar?api_key=$_apiKey&language=$_language&page=$page',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return results.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Échec de la récupération des films similaires');
      }
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des films similaires: $e',
      );
    }
  }

  Future<bool> markMovieAsWatched(int movieId, {bool watched = true}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();
      final List<String> watchedMovies =
          prefs.getStringList('watched_movies') ?? [];

      if (watched) {
        if (!watchedMovies.contains(movieId.toString())) {
          watchedMovies.add(movieId.toString());
        }
      } else {
        watchedMovies.remove(movieId.toString());
      }

      await prefs.setStringList('watched_movies', watchedMovies);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isMovieWatched(int movieId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> watchedMovies =
          prefs.getStringList('watched_movies') ?? [];

      return watchedMovies.contains(movieId.toString());
    } catch (e) {
      return false;
    }
  }

  // ===== COMMON OPERATIONS =====

  String getImageUrl(String path, {String size = TMDbConfig.posterSize}) {
    if (path.isEmpty) return '';
    return '$imageBaseUrl$size$path';
  }

  Future<bool> addToFavorites(int mediaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> favorites = prefs.getStringList('favorites') ?? [];

      if (!favorites.contains(mediaId.toString())) {
        favorites.add(mediaId.toString());
        await prefs.setStringList('favorites', favorites);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromFavorites(int mediaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> favorites = prefs.getStringList('favorites') ?? [];

      favorites.remove(mediaId.toString());
      await prefs.setStringList('favorites', favorites);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isFavorite(int mediaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> favorites = prefs.getStringList('favorites') ?? [];

      return favorites.contains(mediaId.toString());
    } catch (e) {
      return false;
    }
  }

  Future<bool> addToWatchlist(int mediaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> watchlist = prefs.getStringList('watchlist') ?? [];

      if (!watchlist.contains(mediaId.toString())) {
        watchlist.add(mediaId.toString());
        await prefs.setStringList('watchlist', watchlist);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromWatchlist(int mediaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> watchlist = prefs.getStringList('watchlist') ?? [];

      watchlist.remove(mediaId.toString());
      await prefs.setStringList('watchlist', watchlist);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isInWatchlist(int mediaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> watchlist = prefs.getStringList('watchlist') ?? [];

      return watchlist.contains(mediaId.toString());
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

  Future<Map<String, dynamic>> getCredits(
    int id, {
    required MediaType mediaType,
  }) async {
    try {
      String endpoint;

      switch (mediaType) {
        case MediaType.movie:
          endpoint = 'movie';
          break;
        case MediaType.tv:
          endpoint = 'tv';
          break;
        default:
          throw Exception('Type de média non pris en charge pour les crédits');
      }

      final response = await _client.get(
        Uri.parse(
          '$_baseUrl/$endpoint/$id/credits?api_key=$_apiKey&language=$_language',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Échec de la récupération des crédits');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des crédits: $e');
    }
  }
}
