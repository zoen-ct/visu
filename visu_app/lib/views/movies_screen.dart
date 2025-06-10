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
  Set<int> _watchedMovies = {}; // Pour suivre les films vus
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

  void _toggleWatched(SearchResult movie) {
    setState(() {
      if (_watchedMovies.contains(movie.id)) {
        _watchedMovies.remove(movie.id);
      } else {
        _watchedMovies.add(movie.id);
      }

      // Réorganiser la liste pour mettre les films vus en haut
      if (_watchlistMovies != null) {
        _watchlistMovies!.sort((a, b) {
          bool isAWatched = _watchedMovies.contains(a.id);
          bool isBWatched = _watchedMovies.contains(b.id);
          if (isAWatched == isBWatched) return 0;
          return isAWatched ? -1 : 1;
        });
      }
    });
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

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadWatchlistMovies,
            color: const Color(0xFFF8C13A),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Films vus
                ..._watchlistMovies!
                    .where((movie) => _watchedMovies.contains(movie.id))
                    .map((movie) => _buildMovieCard(movie, true)),

                // Label "à voir"
                if (_watchlistMovies!.any(
                  (movie) => !_watchedMovies.contains(movie.id),
                )) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Text(
                      'à voir',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Films non vus
                ..._watchlistMovies!
                    .where((movie) => !_watchedMovies.contains(movie.id))
                    .map((movie) => _buildMovieCard(movie, false)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(SearchResult movie, bool isWatched) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToMovieDetail(movie),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec le titre
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8C13A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      movie.title,
                      style: const TextStyle(
                        color: Color(0xFF16232E),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Contenu principal
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image du film
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(isWatched ? 0.5 : 0),
                            BlendMode.srcATop,
                          ),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                            width: 80,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  width: 80,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.movie,
                                    color: Colors.grey,
                                    size: 32,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Description du film
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.overview,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 14,
                                height: 1.5,
                                decoration:
                                    isWatched
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Bouton vu/à voir
                      GestureDetector(
                        onTap: () => _toggleWatched(movie),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                isWatched
                                    ? const Color(0xFFF8C13A).withOpacity(0.1)
                                    : Colors.grey[200],
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(
                            isWatched
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color:
                                isWatched
                                    ? const Color(0xFFF8C13A)
                                    : Colors.grey[400],
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
