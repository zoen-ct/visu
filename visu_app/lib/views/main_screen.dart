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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        color: const Color(0xFF16232E),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  context,
                  0,
                  Icons.tv_outlined,
                  Icons.tv_rounded,
                  'Séries',
                  currentIndex,
                ),
                _buildNavItem(
                  context,
                  1,
                  Icons.movie_outlined,
                  Icons.movie_rounded,
                  'Films',
                  currentIndex,
                ),
                _buildNavItem(
                  context,
                  2,
                  Icons.search_outlined,
                  Icons.search_rounded,
                  'Recherche',
                  currentIndex,
                ),
                _buildNavItem(
                  context,
                  3,
                  Icons.person_outline_outlined,
                  Icons.person_rounded,
                  'Profil',
                  currentIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    int currentIndex,
  ) {
    final bool isSelected = currentIndex == index;
    return InkWell(
      onTap: () {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
            decoration:
                isSelected
                    ? BoxDecoration(
                      color: const Color(0xFFF8C13A),
                      borderRadius: BorderRadius.circular(16),
                    )
                    : null,
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF16232E) : Colors.grey[600],
              size: 24,
            ),
          ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF16232E),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
