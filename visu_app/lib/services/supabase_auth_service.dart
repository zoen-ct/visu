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
      // Récupérer le username depuis userData ou générer depuis l'email
      final String username = userData?['name'] ?? email.split('@').first;

      // Préparation des données utilisateur avec le username pour les métadonnées
      final userMetadata = {...?userData, 'username': username};

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data:
            userMetadata, // Stockage du username dans les métadonnées de l'utilisateur
      );

      if (response.user != null) {
        // Attendre un peu pour s'assurer que l'utilisateur est bien créé dans la base de données
        await Future.delayed(const Duration(milliseconds: 500));

        try {
          // Insérer les champs obligatoires dans la table user_profiles
          // N'inclure que les champs qui existent réellement dans la table
          await supabase.from(SupabaseConfig.userProfileTable).insert({
            'id': response.user!.id,
            'name': username,
            'profile_picture': SupabaseConfig.defaultProfileImage,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (profileError) {
          SupabaseConfig.logError(
            'Erreur lors de la création du profil utilisateur',
            profileError,
          );
          // On continue malgré l'erreur - le profil pourra être créé plus tard
        }
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

  User? get currentUser => supabase.auth.currentUser;

  Future<String?> getUsername() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        return null;
      }

      // Récupérer le username depuis les métadonnées de l'utilisateur
      final String? username = user.userMetadata?['username'] as String?;

      // Si le username n'est pas trouvé dans les métadonnées, utiliser la partie avant @ de l'email
      return username ?? user.email?.split('@').first;
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de la récupération du nom d\'utilisateur',
        e,
      );
      return null;
    }
  }

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

  Future<void> deleteAccount() async {
    try {
      // Obtenir l'utilisateur actuel
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      // Supprimer les données de l'utilisateur de la table user_profiles
      await supabase
          .from(SupabaseConfig.userProfileTable)
          .delete()
          .eq('id', user.id);

      // Utiliser une solution alternative à admin.deleteUser
      // Mettre à jour les métadonnées de l'utilisateur pour indiquer que le compte est supprimé
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'deleted': true,
            'deleted_at': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Déconnecter l'utilisateur
      await signOut();
    } catch (e) {
      SupabaseConfig.logError('Erreur lors de la suppression du compte', e);
      rethrow;
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
