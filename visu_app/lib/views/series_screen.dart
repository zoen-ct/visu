import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/visu.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  final SerieService _serieService = SerieService();

  List<Serie>? _watchlist;
  bool _isLoadingWatchlist = true;
  String? _watchlistError;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    try {
      setState(() {
        _isLoadingWatchlist = true;
        _watchlistError = null;
      });

      final watchlist = await _serieService.getWatchlist();

      if (mounted) {
        setState(() {
          _watchlist = watchlist;
          _isLoadingWatchlist = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _watchlistError = 'Erreur lors du chargement des séries à voir';
          _isLoadingWatchlist = false;
        });
      }
    }
  }

  void _navigateToSerieDetail(BuildContext context, Serie serie) {
    context.push('/series/detail/${serie.id}');
  }

  Widget _buildContent() {
    if (_isLoadingWatchlist) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF8C13A)),
      );
    }

    if (_watchlistError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _watchlistError!,
              style: const TextStyle(color: Color(0xFFF4F6F8), fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWatchlist,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8C13A),
                foregroundColor: const Color(0xFF16232E),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_watchlist == null || _watchlist!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Aucune série disponible',
              style: TextStyle(color: Color(0xFFF4F6F8), fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/search'),
              icon: const Icon(Icons.search),
              label: const Text('Chercher des séries'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8C13A),
                foregroundColor: const Color(0xFF16232E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWatchlist,
      color: const Color(0xFFF8C13A),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _watchlist!.length,
        itemBuilder: (context, index) {
          final serie = _watchlist![index];
          return SerieCard(
            serie: serie,
            onTap: () => _navigateToSerieDetail(context, serie),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16232E),
        title: const Text(
          'Mes séries',
          style: TextStyle(
            color: Color(0xFFF8C13A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildContent(),
    );
  }
}
