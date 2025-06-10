import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:visu/router/app_router.dart';
import 'package:visu/services/supabase_initializer.dart';

import 'visu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Chargement des variables d'environnement
  await dotenv.load(fileName: ".env");

  // Initialisation de Supabase
  await SupabaseInitializer.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SupabaseAuthService _authService = SupabaseAuthService();

  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(authService: _authService);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Visu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF8C13A),
          primary: const Color(0xFFF8C13A),
          secondary: const Color(0xFF16232E),
          surface: const Color(0xFFF4F6F8),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(fontSize: 14),
        ),
        useMaterial3: true,
      ),
      routerConfig: _appRouter.router,
    );
  }
}
