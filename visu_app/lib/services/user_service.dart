import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/visu.dart';

class UserService {
  final TMDbService _tmdbService = TMDbService();

  Future<List<SearchResult>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList('favorites') ?? [];

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
}
