import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';
import 'supabase_initializer.dart';

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

  bool get isLoggedIn => supabase.auth.currentSession != null;

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
      SupabaseConfig.logError('Erreur lors de la connexion', e);
      rethrow;
    }
  }

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
        await supabase.from(SupabaseConfig.userProfileTable).insert({
          'id': response.user!.id,
          'email': email,
          'name': userData?['name'] ?? email.split('@').first,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return response;
    } catch (e) {
      SupabaseConfig.logError('Erreur lors de l\'inscription', e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      SupabaseConfig.logError('Erreur lors de la déconnexion', e);
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    return supabase.auth.currentUser;
  }

  String? get currentUserId => supabase.auth.currentUser?.id;

  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la réinitialisation du mot de passe',
        e,
      );
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la mise à jour du mot de passe',
        e,
      );
      rethrow;
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
