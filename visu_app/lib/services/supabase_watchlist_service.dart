import '/visu.dart';

class SupabaseWatchlistService {
  final SupabaseAuthService _authService = SupabaseAuthService();
  static const String historyTable = SupabaseConfig.historyTable;
  static const String watchlistPrefix = "WATCHLIST_";

  /// Vérifie si un film ou une série est dans la watchlist
  Future<bool> isInWatchlist({
    required int itemId,
    required MediaType mediaType,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return false;
      }

      // Chercher l'élément avec le préfixe WATCHLIST_ dans le titre
      final result =
          await supabase
              .from(historyTable)
              .select()
              .eq('user_id', userId)
              .eq('item_id', itemId)
              .eq('type', mediaType.name)
              .like('title', '$watchlistPrefix%')
              .maybeSingle();

      return result != null;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la vérification de la watchlist',
        e,
      );
      return false;
    }
  }

  /// Ajoute ou supprime un film ou une série de la watchlist
  Future<bool> toggleWatchlist({
    required int itemId,
    required MediaType mediaType,
    String? title,
    String? posterPath,
    required bool addToWatchlist,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      if (!addToWatchlist) {
        // Supprimer de la watchlist
        await supabase
            .from(historyTable)
            .delete()
            .eq('user_id', userId)
            .eq('item_id', itemId)
            .eq('type', mediaType.name)
            .like('title', '$watchlistPrefix%');

        return true;
      }

      // Vérifier si déjà dans la watchlist
      final alreadyInWatchlist = await isInWatchlist(
        itemId: itemId,
        mediaType: mediaType,
      );

      if (alreadyInWatchlist) {
        return true;
      }

      // Ajouter à la watchlist avec un préfixe pour différencier des éléments vus
      final watchlistEntry = {
        'user_id': userId,
        'item_id': itemId,
        'type': mediaType.name,
        'title': title != null ? '$watchlistPrefix$title' : watchlistPrefix,
        'poster_path': posterPath,
        'watched_at': DateTime.now().toIso8601String(),
      };

      await supabase.from(historyTable).insert(watchlistEntry);

      return true;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la mise à jour de la watchlist',
        e,
      );
      return false;
    }
  }

  /// Récupère tous les éléments de la watchlist
  Future<List<Map<String, dynamic>>> getWatchlist() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return [];
      }

      final result = await supabase
          .from(historyTable)
          .select()
          .eq('user_id', userId)
          .like('title', '$watchlistPrefix%')
          .order('watched_at', ascending: false);

      // Enlever le préfixe des titres pour l'affichage
      return result.map((item) {
        if (item['title'] != null &&
            item['title'].toString().startsWith(watchlistPrefix)) {
          item['title'] = item['title'].toString().substring(
            watchlistPrefix.length,
          );
        }
        return item;
      }).toList();
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la récupération de la watchlist',
        e,
      );
      return [];
    }
  }

  /// Récupère les éléments de la watchlist par type (films ou séries)
  Future<List<Map<String, dynamic>>> getWatchlistByType(
    MediaType mediaType,
  ) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return [];
      }

      final result = await supabase
          .from(historyTable)
          .select()
          .eq('user_id', userId)
          .eq('type', mediaType.name)
          .like('title', '$watchlistPrefix%')
          .order('watched_at', ascending: false);

      // Enlever le préfixe des titres pour l'affichage
      return result.map((item) {
        if (item['title'] != null &&
            item['title'].toString().startsWith(watchlistPrefix)) {
          item['title'] = item['title'].toString().substring(
            watchlistPrefix.length,
          );
        }
        return item;
      }).toList();
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la récupération de la watchlist par type',
        e,
      );
      return [];
    }
  }

  /// Supprime tous les éléments de la watchlist
  Future<bool> clearWatchlist({MediaType? mediaType}) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final query = supabase
          .from(historyTable)
          .delete()
          .eq('user_id', userId)
          .like('title', '$watchlistPrefix%');

      if (mediaType != null) {
        await query.eq('type', mediaType.name);
      } else {
        await query;
      }

      return true;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la suppression de la watchlist',
        e,
      );
      return false;
    }
  }
}
