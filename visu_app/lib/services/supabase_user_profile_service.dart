import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

import '/visu.dart';

class SupabaseUserProfileService {
  final String _tableName = SupabaseConfig.userProfileTable;

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final data =
          await supabase
              .from(_tableName)
              .select()
              .eq('user_id', userId)
              .single();

      return data;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du profil: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile({
    String? username,
    String? avatarUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final existingProfile = await supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId);

      final Map<String, dynamic> updateData = {};

      if (username != null) updateData['username'] = username;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (additionalData != null) updateData.addAll(additionalData);
      updateData['updated_at'] = DateTime.now().toIso8601String();

      if (existingProfile.isEmpty) {
        updateData['user_id'] = userId;
        updateData['created_at'] = DateTime.now().toIso8601String();
        await supabase.from(_tableName).insert(updateData);
      } else {
        await supabase
            .from(_tableName)
            .update(updateData)
            .eq('user_id', userId);
      }

      return true;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du profil: $e');
      return false;
    }
  }

  Future<String?> uploadAvatar(List<int> fileBytes, String fileName) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final String fileExt = fileName.split('.').last;
      final String filePath = 'avatars/$userId/avatar.$fileExt';

      await supabase.storage.from('avatars').remove(['$userId/']);
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

      await updateUserProfile(avatarUrl: publicUrl);

      return publicUrl;
    } catch (e) {
      debugPrint('Erreur lors de l\'upload de l\'avatar: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getPreferences() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await supabase
          .from('user_preferences')
          .select()
          .eq('user_id', userId);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Erreur lors de la récupération des préférences: $e');
      return [];
    }
  }

  Future<bool> savePreference({
    required String key,
    required dynamic value,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final existingPrefs = await supabase
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .eq('key', key);

      if (existingPrefs.isEmpty) {
        await supabase.from('user_preferences').insert({
          'user_id': userId,
          'key': key,
          'value': value,
        });
      } else {
        await supabase
            .from('user_preferences')
            .update({'value': value})
            .eq('user_id', userId)
            .eq('key', key);
      }

      return true;
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de la préférence: $e');
      return false;
    }
  }
}
