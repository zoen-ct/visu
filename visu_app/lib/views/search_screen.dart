import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16232E),
        title: const Text(
          'Recherche',
          style: TextStyle(color: Color(0xFFF8C13A)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un film ou une série...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF4F6F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF16232E)),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Trouvez vos contenus préférés',
                style: TextStyle(color: Color(0xFFF4F6F8), fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
