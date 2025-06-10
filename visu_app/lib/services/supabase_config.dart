import 'package:flutter/material.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ijlwszhwhidewrekkyjn.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlqbHdzemh3aGlkZXdyZWtreWpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk1NDM2NzYsImV4cCI6MjA2NTExOTY3Nn0.Fw7ajRBfdc8njw-bQhTtyvHSyqYKuuiA6VqGZ9K27Ik';

  static const String userProfileTable = 'user_profiles';
  static const String favoritesTable = 'favorites';
  static const String historyTable = 'watch_history';
  static const String userPreferencesTable = 'user_preferences';

  static const String defaultProfileImage =
      'https://gravatar.com/avatar/placeholder?d=mp';

  static const String authError = 'Erreur d\'authentification';
  static const String networkError =
      'Erreur réseau, veuillez vérifier votre connexion';
  static const String generalError =
      'Une erreur s\'est produite, veuillez réessayer';

  static void logError(String message, dynamic error) {
    debugPrint('Erreur Supabase: $message');
    debugPrint('Détails: $error');
  }
}
