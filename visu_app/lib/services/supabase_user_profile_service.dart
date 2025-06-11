import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/visu.dart';

class SupabaseUserProfileService {
  final SupabaseAuthService _authService = SupabaseAuthService();

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final response =
          await supabase
              .from(SupabaseConfig.userProfileTable)
              .select()
              .eq('id', userId)
              .maybeSingle();

      if (response == null) {
        return await _createDefaultProfile(userId);
      }

      return response;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la récupération du profil utilisateur',
        e,
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> _createDefaultProfile(String userId) async {
    try {
      final userInfo = await supabase.auth.getUser();
      final email = userInfo.user?.email ?? '';

      final defaultProfile = {
        'id': userId,
        'email': email,
        'username':
            'Visueur',
        'avatar_url': null,
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabase
          .from(SupabaseConfig.userProfileTable)
          .insert(defaultProfile);

      return defaultProfile;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la création du profil utilisateur par défaut',
        e,
      );
      return null;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      await supabase
          .from(SupabaseConfig.userProfileTable)
          .update(userData)
          .eq('id', userId);

      return true;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la mise à jour du profil utilisateur',
        e,
      );
      return false;
    }
  }

  Future<String?> updateProfilePicture(
    List<int> fileBytes,
    String fileExt,
  ) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final String filePath = 'profile_pictures/$userId.$fileExt';
      await supabase.storage
          .from('avatars')
          .uploadBinary(
            filePath,
            Uint8List.fromList(fileBytes),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String publicUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      await updateUserProfile({'avatar_url': publicUrl});

      return publicUrl;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la mise à jour de la photo de profil',
        e,
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserPreferences() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final response =
          await supabase
              .from(SupabaseConfig.userPreferencesTable)
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      return response;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la récupération des préférences utilisateur',
        e,
      );
      return null;
    }
  }

  Future<bool> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final data = {...preferences, 'user_id': userId};

      final existingPrefs = await getUserPreferences();

      if (existingPrefs != null) {
        await supabase
            .from(SupabaseConfig.userPreferencesTable)
            .update(data)
            .eq('user_id', userId);
      } else {
        await supabase.from(SupabaseConfig.userPreferencesTable).insert(data);
      }

      return true;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la mise à jour des préférences utilisateur',
        e,
      );
      return false;
    }
  }

  Future<String> getAvatarUrl() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return SupabaseConfig.defaultProfileImage;
      }

      final response =
          await supabase
              .from(SupabaseConfig.userProfileTable)
              .select('avatar_url')
              .eq('id', userId)
              .maybeSingle();

      if (response != null && response['avatar_url'] != null) {
        return response['avatar_url'];
      }

      return SupabaseConfig.defaultProfileImage;
    } catch (e) {
      SupabaseConfig.logError('Erreur lors de la récupération de l\'avatar', e);
      return SupabaseConfig
          .defaultProfileImage;
    }
  }

  Future<bool> updateUsername(String? username) async {
    final String usernameToUse =
        (username == null || username.isEmpty) ? 'Visueur' : username;

    return await updateUserProfile({'username': usernameToUse});
  }
}
