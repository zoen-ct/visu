import 'dart:async';
import 'package:flutter/material.dart';

import '/visu.dart';

class AuthService {
  final SupabaseAuthService _supabaseAuthService = SupabaseAuthService();

  Stream<bool> get authStateChanges => _supabaseAuthService.authStateChanges;

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseAuthService.signIn(
        email: email,
        password: password,
      );

      return response.session != null;
    } catch (e) {
      debugPrint('Erreur lors de la connexion: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    return _supabaseAuthService.isLoggedIn;
  }

  bool isLoggedInSync() {
    return _supabaseAuthService.isLoggedIn;
  }

  Future<void> logout() async {
    try {
      await _supabaseAuthService.signOut();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final user = await _supabaseAuthService.getCurrentUser();
      if (user == null) return null;

      final userProfileService = SupabaseUserProfileService();
      final profile = await userProfileService.getUserProfile();

      return {'id': user.id, 'email': user.email, ...?profile};
    } catch (e) {
      debugPrint('Erreur lors de la récupération des infos utilisateur: $e');
      return null;
    }
  }
}
