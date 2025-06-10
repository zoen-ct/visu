import '/visu.dart';

class SupabaseFavoritesService {
  final SupabaseAuthService _authService = SupabaseAuthService();

  Future<bool> isFavorite({
    required int itemId,
    required MediaType mediaType,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return false;
      }

      final result =
          await supabase
              .from(SupabaseConfig.favoritesTable)
              .select()
              .eq('user_id', userId)
              .eq('item_id', itemId)
              .eq('type', mediaType.name)
              .maybeSingle();

      return result != null;
    } catch (e) {
      SupabaseConfig.logError('Erreur lors de la vérification des favoris', e);
      return false;
    }
  }

  Future<bool> addToFavorites({
    required int itemId,
    required MediaType mediaType,
    required String title,
    String? posterPath,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final alreadyFavorite = await isFavorite(
        itemId: itemId,
        mediaType: mediaType,
      );

      if (alreadyFavorite) {
        return true;
      }

      await supabase.from(SupabaseConfig.favoritesTable).insert({
        'user_id': userId,
        'item_id': itemId,
        'type': mediaType.name,
        'title': title,
        'poster_path': posterPath,
        'added_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      SupabaseConfig.logError('Erreur lors de l\'ajout aux favoris', e);
      return false;
    }
  }

  Future<bool> removeFromFavorites({
    required int itemId,
    required MediaType mediaType,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      await supabase
          .from(SupabaseConfig.favoritesTable)
          .delete()
          .eq('user_id', userId)
          .eq('item_id', itemId)
          .eq('type', mediaType.name);

      return true;
    } catch (e) {
      SupabaseConfig.logError('Erreur lors de la suppression des favoris', e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return [];
      }

      final result = await supabase
          .from(SupabaseConfig.favoritesTable)
          .select()
          .eq('user_id', userId)
          .order('added_at', ascending: false);

      return result;
    } catch (e) {
      SupabaseConfig.logError('Erreur lors de la récupération des favoris', e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFavoritesByType(
    MediaType mediaType,
  ) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return [];
      }

      final result = await supabase
          .from(SupabaseConfig.favoritesTable)
          .select()
          .eq('user_id', userId)
          .eq('type', mediaType.name)
          .order('added_at', ascending: false);

      return result;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la récupération des favoris par type',
        e,
      );
      return [];
    }
  }
}
