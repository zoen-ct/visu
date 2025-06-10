import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/services/supabase_initializer.dart';

class SupabaseAuthService {
  SupabaseAuthService() {
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.signedUp) {
        _authStateController.add(true);
      } else if (event == AuthChangeEvent.signedOut) {
        _authStateController.add(false);
      }
    });
  }

  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  Stream<bool> get authStateChanges => _authStateController.stream;

  User? get currentUser => supabase.auth.currentUser;

  Session? get currentSession => supabase.auth.currentSession;

  bool get isLoggedIn => currentUser != null;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );

      if (response.user != null) {
        await supabase.from('user_profile').insert({
          'user_id': response.user!.id,
          'username':
              email
                  .split('@')
                  .first,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    String? email,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await supabase.auth.updateUser(
        UserAttributes(email: email, data: data),
      );
      return response.user!.userMetadata!;
    } catch (e) {
      rethrow;
    }
  }
}
