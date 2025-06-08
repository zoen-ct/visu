import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/visu.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final SerieService _serieService = SerieService();

  List<Serie>? _watchlist;
  List<Serie>? _upcoming;

  bool _isLoadingWatchlist = true;
  bool _isLoadingUpcoming = true;

  String? _watchlistError;
  String? _upcomingError;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _loadWatchlist();
    _loadUpcoming();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _loadUpcoming() async {
    try {
      setState(() {
        _isLoadingUpcoming = true;
        _upcomingError = null;
      });

      final upcoming = await _serieService.getUpcoming();

      if (mounted) {
        setState(() {
          _upcoming = upcoming;
          _isLoadingUpcoming = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _upcomingError = 'Erreur lors du chargement des séries à venir';
          _isLoadingUpcoming = false;
        });
      }
    }
  }

  void _navigateToSerieDetail(BuildContext context, Serie serie) {
    context.push('/series/detail/${serie.id}');
  }

  Widget _buildWatchlistTab() {
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
      return const Center(
        child: Text(
          'Aucune série disponible',
          style: TextStyle(color: Color(0xFFF4F6F8), fontSize: 16),
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

  Widget _buildUpcomingTab() {
    if (_isLoadingUpcoming) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF8C13A)),
      );
    }

    if (_upcomingError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _upcomingError!,
              style: const TextStyle(color: Color(0xFFF4F6F8), fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUpcoming,
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

    if (_upcoming == null || _upcoming!.isEmpty) {
      return const Center(
        child: Text(
          'Aucune série à venir',
          style: TextStyle(color: Color(0xFFF4F6F8), fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUpcoming,
      color: const Color(0xFFF8C13A),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _upcoming!.length,
        itemBuilder: (context, index) {
          final serie = _upcoming![index];
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
          'Séries',
          style: TextStyle(
            color: Color(0xFFF8C13A),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF8C13A),
          labelColor: const Color(0xFFF8C13A),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [Tab(text: 'À voir'), Tab(text: 'À venir')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildWatchlistTab(), _buildUpcomingTab()],
      ),
    );
  }
}
