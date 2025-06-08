import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/visu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16232E),
        title: const Text(
          'Vizu - Accueil',
          style: TextStyle(color: Color(0xFFF8C13A)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF8C13A)),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Bienvenue sur Vizu!',
          style: TextStyle(
            color: Color(0xFFF4F6F8),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
