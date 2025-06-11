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
  final SupabaseHistoryService _historyService = SupabaseHistoryService();
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

      final historyItems = await _historyService.getHistory();
      final Set<int> watchedMovieIds =
          historyItems
              .where((item) => item['type'] == MediaType.movie.name)
              .map<int>((item) => item['item_id'] as int)
              .toSet();

      final List<SearchResult> movies = [];
      for (final item in watchlistItems) {
        try {
          final int movieId = item['item_id'];

          if (watchedMovieIds.contains(movieId)) {
            continue;
          }

          final movieDetails = await _tmdbService.getMovieDetails(movieId);

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

  void _navigateToSearch() {
    context.push('/search');
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_errorMessage != null) {
      return ErrorDisplay(
        message: _errorMessage!,
        onRetry: _loadWatchlistMovies,
      );
    }

    if (_watchlistMovies == null || _watchlistMovies!.isEmpty) {
      return EmptyStateView(
        title: 'Votre watchlist de films est vide',
        subtitle: 'Recherchez des films pour les ajouter à votre liste',
        icon: Icons.movie_outlined,
        actionLabel: 'Chercher des films',
        actionIcon: Icons.search,
        onAction: _navigateToSearch,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWatchlistMovies,
      color: const Color(0xFFF8C13A),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _watchlistMovies!.length + 1, // +1 for bottom margin
        itemBuilder: (context, index) {
          if (index == _watchlistMovies!.length) {
            return const SizedBox(height: 100);
          }
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
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
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
