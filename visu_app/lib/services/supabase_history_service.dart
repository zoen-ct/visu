import 'package:flutter/material.dart';

import '/visu.dart';

class SupabaseHistoryService {
  final String _tableName = SupabaseConfig.historyTable;

  Future<bool> markAsWatched({
    required int itemId,
    required MediaType mediaType,
    int? seasonNumber,
    int? episodeNumber,
    String? title,
    String? posterPath,
    bool watched = true,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      if (watched) {
        final existingData = await supabase
            .from(_tableName)
            .select()
            .eq('user_id', userId)
            .eq('item_id', itemId)
            .eq('type', mediaType.name)
            .eq('season_number', seasonNumber!)
            .eq('episode_number', episodeNumber!);

        if (existingData.isEmpty) {
          await supabase.from(_tableName).insert({
            'user_id': userId,
            'item_id': itemId,
            'type': mediaType.name,
            'season_number': seasonNumber,
            'episode_number': episodeNumber,
            'title': title,
            'poster_path': posterPath,
            'watched_at': DateTime.now().toIso8601String(),
          });
        } else {
          await supabase
              .from(_tableName)
              .update({'watched_at': DateTime.now().toIso8601String()})
              .eq('user_id', userId)
              .eq('item_id', itemId)
              .eq('type', mediaType.name)
              .eq('season_number', seasonNumber)
              .eq('episode_number', episodeNumber);
        }
      } else {
        await supabase
            .from(_tableName)
            .delete()
            .eq('user_id', userId)
            .eq('item_id', itemId)
            .eq('type', mediaType.name)
            .eq('season_number', seasonNumber!)
            .eq('episode_number', episodeNumber!);
      }

      return true;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de l\'historique: $e');
      return false;
    }
  }

  Future<bool> isWatched({
    required int itemId,
    required MediaType mediaType,
    int? seasonNumber,
    int? episodeNumber,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      var query = supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('item_id', itemId)
          .eq('type', mediaType.name);

      if (seasonNumber != null) {
        query = query.eq('season_number', seasonNumber);
      }

      if (episodeNumber != null) {
        query = query.eq('episode_number', episodeNumber);
      }

      final data = await query;
      return data.isNotEmpty;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de l\'historique: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getHistory({
    MediaType? mediaType,
    int limit = 20,
    int offset = 0,
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

      query.order('watched_at', ascending: false)
        .range(offset, offset + limit - 1);

      final data = await query;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }
}
