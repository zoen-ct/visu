import 'package:flutter/material.dart';
import 'package:visu/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16232E),
        title: const Text('Profil', style: TextStyle(color: Color(0xFFF8C13A))),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFF8C13A),
              child: Icon(Icons.person, size: 50, color: Color(0xFF16232E)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Utilisateur Vizu',
              style: TextStyle(
                color: Color(0xFFF4F6F8),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'utilisateur@vizu.com',
              style: TextStyle(color: Color(0xFFF4F6F8), fontSize: 16),
            ),
            const SizedBox(height: 30),
            _buildProfileOption(Icons.favorite, 'Mes favoris'),
            _buildProfileOption(Icons.history, 'Historique'),
            _buildProfileOption(Icons.settings, 'Paramètres'),
            _buildProfileOption(Icons.help_outline, 'Aide'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      child: Card(
        color: const Color(0xFF1D2F3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFFF8C13A)),
          title: Text(text, style: const TextStyle(color: Color(0xFFF4F6F8))),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFFF8C13A),
            size: 16,
          ),
          onTap: () {
            // Navigate to the corresponding page
          },
        ),
      ),
    );
  }
}
