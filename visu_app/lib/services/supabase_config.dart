import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

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
