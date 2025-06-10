import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

late final SupabaseClient supabase;

class SupabaseInitializer {
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: true,
      );

      supabase = Supabase.instance.client;

      debugPrint('Supabase initialisé avec succès');
    } catch (e) {
      SupabaseConfig.logError(
        'Erreur lors de l\'initialisation de Supabase',
        e,
      );
      rethrow;
    }
  }
}
