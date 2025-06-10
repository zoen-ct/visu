import 'package:flutter/material.dart';

import '/visu.dart';

class SerieService {
  final TMDbService _tmdbService = TMDbService();
  final SupabaseHistoryService _historyService = SupabaseHistoryService();
  final SupabaseFavoritesService _favoritesService = SupabaseFavoritesService();

  Future<List<Serie>> getWatchlist() async {
    try {
      final watchlistItems = await _historyService.getHistoryByType(
        MediaType.tv,
      );

      final List<Serie> series = [];
      for (final item in watchlistItems) {
        try {
          final serieDetails = await _tmdbService.getTvShowDetails(
            item['item_id'],
          );
          series.add(
            Serie(
              id: serieDetails.id,
              title: serieDetails.name,
              imageUrl:
                  'https://image.tmdb.org/t/p/w500${serieDetails.posterPath}',
              rating: serieDetails.voteAverage,
              releaseDate: serieDetails.firstAirDate,
              description: serieDetails.overview,
              genres: serieDetails.genres.map((genre) => genre.name).toList(),
            ),
          );
        } catch (e) {
          debugPrint(
            'Erreur lors de la récupération des détails de la série: $e',
          );
        }
      }
      return series;
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la watchlist: $e');
      return [];
    }
  }

  Future<List<Serie>> getUpcoming() async {
    try {
      final onAirSeries = await _tmdbService.getTrendingSeries(
        timeWindow: 'day',
      );

      return onAirSeries.take(5).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des séries à venir: $e');
      return [];
    }
  }

  Future<List<Serie>> getPopularSeries() async {
    try {
      return await _tmdbService.getPopularSeries();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des séries populaires: $e');
      return [];
    }
  }

  Future<List<Serie>> searchSeries(String query) async {
    try {
      if (query.isEmpty) {
        return await getPopularSeries();
      }
      return await _tmdbService.searchSeries(query);
    } catch (e) {
      debugPrint('Erreur lors de la recherche de séries: $e');
      return [];
    }
  }
}
