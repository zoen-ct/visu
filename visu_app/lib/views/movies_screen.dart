import 'package:flutter/material.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16232E),
        title: const Text('Films', style: TextStyle(color: Color(0xFFF8C13A))),
      ),
      body: const Center(
        child: Text(
          'Explorez les meilleurs films',
          style: TextStyle(color: Color(0xFFF4F6F8), fontSize: 18),
        ),
      ),
    );
  }
}
