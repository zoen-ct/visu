import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  final Widget child;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFF16232E),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
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
            backgroundColor: Colors.transparent,
            indicatorColor: const Color(0xFFF8C13A),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            height: 65,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.tv_outlined, color: Colors.grey[600]),
                selectedIcon: const Icon(
                  Icons.tv_rounded,
                  color: Color(0xFF16232E),
                ),
                label: 'Séries',
              ),
              NavigationDestination(
                icon: Icon(Icons.movie_outlined, color: Colors.grey[600]),
                selectedIcon: const Icon(
                  Icons.movie_rounded,
                  color: Color(0xFF16232E),
                ),
                label: 'Films',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined, color: Colors.grey[600]),
                selectedIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF16232E),
                ),
                label: 'Recherche',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.person_outline_outlined,
                  color: Colors.grey[600],
                ),
                selectedIcon: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF16232E),
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
