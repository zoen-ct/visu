import 'package:flutter/material.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16232E),
        title: const Text('Séries', style: TextStyle(color: Color(0xFFF8C13A))),
      ),
      body: const Center(
        child: Text(
          'Découvrez vos séries préférées',
          style: TextStyle(color: Color(0xFFF4F6F8), fontSize: 18),
        ),
      ),
    );
  }
}
