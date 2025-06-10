import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/visu.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final SupabaseWatchlistService _watchlistService = SupabaseWatchlistService();
  final TMDbService _tmdbService = TMDbService();

  List<SearchResult>? _watchlistMovies;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWatchlistMovies();
  }

  Future<void> _loadWatchlistMovies() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final watchlistItems = await _watchlistService.getWatchlistByType(
        MediaType.movie,
      );

      final List<SearchResult> movies = [];
      for (final item in watchlistItems) {
        try {
          final movieDetails = await _tmdbService.getMovieDetails(
            item['item_id'],
          );

          movies.add(
            SearchResult.fromJson({
              'id': movieDetails['id'],
              'title': movieDetails['title'],
              'poster_path': movieDetails['poster_path'],
              'vote_average': movieDetails['vote_average'],
              'release_date': movieDetails['release_date'],
              'overview': movieDetails['overview'],
              'media_type': 'movie',
            }),
          );
        } catch (e) {
          debugPrint(
            'Erreur lors du chargement du film ${item['item_id']}: $e',
          );
        }
      }

      if (mounted) {
        setState(() {
          _watchlistMovies = movies;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Erreur lors du chargement des films de votre watchlist';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToMovieDetail(SearchResult movie) {
    context.push('/movies/detail/${movie.id}');
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF8C13A)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFF4F6F8), fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWatchlistMovies,
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

    if (_watchlistMovies == null || _watchlistMovies!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_outlined,
              color: Color(0xFFF8C13A),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Votre watchlist de films est vide',
              style: TextStyle(color: Color(0xFFF4F6F8), fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Recherchez des films pour les ajouter à votre liste',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/search'),
              icon: const Icon(Icons.search),
              label: const Text('Chercher des films'),
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
      onRefresh: _loadWatchlistMovies,
      color: const Color(0xFFF8C13A),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _watchlistMovies!.length,
        itemBuilder: (context, index) {
          final movie = _watchlistMovies![index];
          return MovieCard(
            movie: movie,
            onTap: () => _navigateToMovieDetail(movie),
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
          'Mes Films',
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
