import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/visu.dart';

late final SupabaseClient supabase;

class SupabaseInitializer {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      debug: kDebugMode,
    );

    supabase = Supabase.instance.client;
  }
}
