import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/visu.dart';

class UserService {
  final AuthService _authService = AuthService();
  final TMDbService _tmdbService = TMDbService();

  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      return await _authService.getCurrentUser();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des infos utilisateur: $e');
      return null;
    }
  }

  Future<List<SearchResult>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList('favorites') ?? [];

      // If we were using a real backend, we would make an API call here
      // But for our simulation, we'll retrieve the details of each ID from TMDb

      final List<SearchResult> favorites = [];
      for (final String id in favoritesList) {
        try {
          final response = await _tmdbService.getMediaDetails(int.parse(id));
          favorites.add(response);
        } catch (e) {
          debugPrint('Erreur lors de la récupération des détails du média: $e');
        }
      }

      return favorites;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des favoris: $e');
      return [];
    }
  }

  Future<List<SearchResult>> getWatchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchedEpisodes = prefs.getStringList('watched_episodes') ?? [];
      final watchedMovies = prefs.getStringList('watched_movies') ?? [];

      // If we were using a real backend, we would make an API call here
      // But for our simulation, we'll retrieve the details of each ID from TMDb

      final List<SearchResult> history = [];

      for (final String id in watchedMovies) {
        try {
          final response = await _tmdbService.getMediaDetails(
            int.parse(id),
            mediaType: MediaType.movie,
          );
          history.add(response);
        } catch (e) {
          debugPrint('Erreur lors de la récupération des détails du film: $e');
        }
      }

      for (final String id in watchedEpisodes) {
        try {
          final episodeData = prefs.getString('episode_$id');
          if (episodeData != null) {
            final episodeInfo = jsonDecode(episodeData) as Map<String, dynamic>;
            final serieId = episodeInfo['serieId'];

            if (!history.any(
              (item) => item.id == serieId && item.mediaType == MediaType.tv,
            )) {
              final response = await _tmdbService.getMediaDetails(
                serieId,
                mediaType: MediaType.tv,
              );
              history.add(response);
            }
          }
        } catch (e) {
          debugPrint(
            'Erreur lors de la récupération des détails de l\'épisode: $e',
          );
        }
      }

      // @TODO : Trier par date de visionnage
      return history;
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchedEpisodes = prefs.getStringList('watched_episodes') ?? [];
      final watchedMovies = prefs.getStringList('watched_movies') ?? [];
      final favoritesList = prefs.getStringList('favorites') ?? [];

      final episodeTimeInMinutes = watchedEpisodes.length * 45;
      final movieTimeInMinutes = watchedMovies.length * 120;
      final totalTimeInMinutes = episodeTimeInMinutes + movieTimeInMinutes;

      final totalHours = totalTimeInMinutes / 60;

      return {
        'totalWatchedEpisodes': watchedEpisodes.length,
        'totalWatchedMovies': watchedMovies.length,
        'totalFavorites': favoritesList.length,
        'totalWatchTimeHours': totalHours.round(),
      };
    } catch (e) {
      debugPrint('Erreur lors de la récupération des statistiques: $e');
      return {
        'totalWatchedEpisodes': 0,
        'totalWatchedMovies': 0,
        'totalFavorites': 0,
        'totalWatchTimeHours': 0,
      };
    }
  }
}
