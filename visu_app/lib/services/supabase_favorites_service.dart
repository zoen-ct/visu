import 'package:flutter/material.dart';

import '/visu.dart';

class SupabaseFavoritesService {
  final String _tableName = SupabaseConfig.favoritesTable;

  Future<bool> addToFavorites({
    required int itemId,
    required MediaType mediaType,
    String? title,
    String? posterPath,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final existingData = await supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('item_id', itemId)
          .eq('type', mediaType.name);

      if (existingData.isNotEmpty) {
        return true;
      }

      await supabase.from(_tableName).insert({
        'user_id': userId,
        'item_id': itemId,
        'type': mediaType.name,
        'title': title,
        'poster_path': posterPath,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout aux favoris: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites({
    required int itemId,
    required MediaType mediaType,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await supabase
          .from(_tableName)
          .delete()
          .eq('user_id', userId)
          .eq('item_id', itemId)
          .eq('type', mediaType.name);

      return true;
    } catch (e) {
      debugPrint('Erreur lors de la suppression des favoris: $e');
      return false;
    }
  }

  Future<bool> isFavorite({
    required int itemId,
    required MediaType mediaType,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final data = await supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('item_id', itemId)
          .eq('type', mediaType.name);

      return data.isNotEmpty;
    } catch (e) {
      debugPrint('Erreur lors de la vérification des favoris: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites({
    MediaType? mediaType,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final query = supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId);

      if (mediaType != null) {
        query.eq('type', mediaType.name);
      }

      query.order('created_at', ascending: false);

      final data = await query;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Erreur lors de la récupération des favoris: $e');
      return [];
    }
  }
}
