import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {

  const MainScreen({super.key, required this.child, required this.currentIndex});

  final Widget child;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/series');
              break;
            case 1:
              context.go('/movies');
              break;
            case 2:
              context.go('/search');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF16232E),
        selectedItemColor: const Color(0xFFF8C13A),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Séries'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Films'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
