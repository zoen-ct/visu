import '/visu.dart';

class SupabaseHistoryService {
  final SupabaseAuthService _authService = SupabaseAuthService();
  // Utiliser la même constante que dans SupabaseWatchlistService pour cohérence
  static const String watchlistPrefix = "WATCHLIST_";

  Future<bool> isWatched({
    required int itemId,
    required MediaType mediaType,
    int? seasonNumber,
    int? episodeNumber,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return false;
      }

      final query = supabase
          .from(SupabaseConfig.historyTable)
          .select()
          .eq('user_id', userId)
          .eq('item_id', itemId)
          .eq('type', mediaType.name)
          .not(
            'title',
            'like',
            '$watchlistPrefix%',
          ); // Exclure les éléments de la watchlist

      if (mediaType == MediaType.tv &&
          seasonNumber != null &&
          episodeNumber != null) {
        final result =
            await query
                .eq('season_number', seasonNumber)
                .eq('episode_number', episodeNumber)
                .maybeSingle();
        return result != null;
      } else {
        final result = await query.maybeSingle();
        return result != null;
      }
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la vérification de l\'historique',
        e,
      );
      return false;
    }
  }

  Future<bool> markAsWatched({
    required int itemId,
    required MediaType mediaType,
    String? title,
    String? posterPath,
    int? seasonNumber,
    int? episodeNumber,
    required bool watched,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      if (!watched) {
        final query = supabase
            .from(SupabaseConfig.historyTable)
            .delete()
            .eq('user_id', userId)
            .eq('item_id', itemId)
            .eq('type', mediaType.name)
            .not(
              'title',
              'like',
              '$watchlistPrefix%',
            ); // Supprimer seulement les éléments vus, pas ceux de la watchlist

        if (mediaType == MediaType.tv &&
            seasonNumber != null &&
            episodeNumber != null) {
          await query
              .eq('season_number', seasonNumber)
              .eq('episode_number', episodeNumber);
        } else {
          await query;
        }

        return true;
      }

      final alreadyWatched = await isWatched(
        itemId: itemId,
        mediaType: mediaType,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      );

      if (alreadyWatched) {
        return true;
      }

      // Vérifier si l'élément est déjà dans la watchlist et le supprimer
      final watchlistService = SupabaseWatchlistService();
      final isInWatchlist = await watchlistService.isInWatchlist(
        itemId: itemId,
        mediaType: mediaType,
      );

      if (isInWatchlist) {
        // Supprimer de la watchlist puisqu'il va être marqué comme vu
        await watchlistService.toggleWatchlist(
          itemId: itemId,
          mediaType: mediaType,
          addToWatchlist: false,
        );
      }

      final historyEntry = {
        'user_id': userId,
        'item_id': itemId,
        'type': mediaType.name,
        'title': title,
        'poster_path': posterPath,
        'watched_at': DateTime.now().toIso8601String(),
      };

      if (mediaType == MediaType.tv &&
          seasonNumber != null &&
          episodeNumber != null) {
        historyEntry['season_number'] = seasonNumber;
        historyEntry['episode_number'] = episodeNumber;
      }

      await supabase.from(SupabaseConfig.historyTable).insert(historyEntry);

      return true;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la mise à jour de l\'historique',
        e,
      );
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return [];
      }

      final result = await supabase
          .from(SupabaseConfig.historyTable)
          .select()
          .eq('user_id', userId)
          .not(
            'title',
            'like',
            '$watchlistPrefix%',
          ) // Exclure les éléments de la watchlist
          .order('watched_at', ascending: false);

      return result;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la récupération de l\'historique',
        e,
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHistoryByType(
    MediaType mediaType,
  ) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return [];
      }

      final result = await supabase
          .from(SupabaseConfig.historyTable)
          .select()
          .eq('user_id', userId)
          .eq('type', mediaType.name)
          .not(
            'title',
            'like',
            '$watchlistPrefix%',
          ) // Exclure les éléments de la watchlist
          .order('watched_at', ascending: false);

      return result;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la récupération de l\'historique par type',
        e,
      );
      return [];
    }
  }

  Future<bool> clearHistory({MediaType? mediaType}) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final query = supabase
          .from(SupabaseConfig.historyTable)
          .delete()
          .eq('user_id', userId)
          .not(
            'title',
            'like',
            '$watchlistPrefix%',
          ); // Supprimer seulement les éléments vus, pas ceux de la watchlist

      if (mediaType != null) {
        await query.eq('type', mediaType.name);
      } else {
        await query;
      }

      return true;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la suppression de l\'historique',
        e,
      );
      return false;
    }
  }
}
