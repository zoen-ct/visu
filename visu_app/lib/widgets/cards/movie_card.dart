import 'package:flutter/material.dart';
import 'package:visu/visu.dart';

/// Widget représentant une carte de film avec ses fonctionnalités
class MovieCard extends StatefulWidget {
  const MovieCard({super.key, required this.movie, required this.onTap});

  final SearchResult movie;
  final VoidCallback onTap;

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  final SupabaseWatchlistService _watchlistService = SupabaseWatchlistService();
  final SupabaseHistoryService _historyService = SupabaseHistoryService();
  bool _isInWatchlist = false;
  bool _isWatched = false;
  bool _isLoadingWatchlist = false;
  bool _isLoadingWatched = false;

  @override
  void initState() {
    super.initState();
    _checkWatchlistStatus();
    _checkWatchedStatus();
  }

  Future<void> _checkWatchlistStatus() async {
    try {
      final isInWatchlist = await _watchlistService.isInWatchlist(
        itemId: widget.movie.id,
        mediaType: MediaType.movie,
      );

      if (mounted) {
        setState(() {
          _isInWatchlist = isInWatchlist;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la watchlist: $e');
    }
  }

  Future<void> _checkWatchedStatus() async {
    try {
      final isWatched = await _historyService.isWatched(
        itemId: widget.movie.id,
        mediaType: MediaType.movie,
      );

      if (mounted) {
        setState(() {
          _isWatched = isWatched;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification du statut de visionnage: $e');
    }
  }

  Future<void> _toggleWatchlist() async {
    if (_isLoadingWatchlist) return;

    setState(() {
      _isLoadingWatchlist = true;
    });

    try {
      bool success = await _watchlistService.toggleWatchlist(
        itemId: widget.movie.id,
        mediaType: MediaType.movie,
        title: widget.movie.title,
        posterPath: widget.movie.posterPath,
        addToWatchlist: !_isInWatchlist,
      );

      if (mounted && success) {
        setState(() {
          _isInWatchlist = !_isInWatchlist;
          _isLoadingWatchlist = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isInWatchlist
                  ? 'Ajouté à la watchlist'
                  : 'Retiré de la watchlist',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF16232E),
          ),
        );
      } else if (mounted) {
        setState(() {
          _isLoadingWatchlist = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWatchlist = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleWatched() async {
    if (_isLoadingWatched) return;

    setState(() {
      _isLoadingWatched = true;
    });

    try {
      bool success = await _historyService.markAsWatched(
        itemId: widget.movie.id,
        mediaType: MediaType.movie,
        watched: !_isWatched,
        title: widget.movie.title,
        posterPath: widget.movie.posterPath,
      );

      if (mounted && success) {
        setState(() {
          _isWatched = !_isWatched;
          _isLoadingWatched = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isWatched ? 'Marqué comme vu' : 'Marqué comme non vu',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF16232E),
          ),
        );
      } else if (mounted) {
        setState(() {
          _isLoadingWatched = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWatched = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaCard(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image and buttons
          Stack(
            children: [
              // Movie image
              MediaPoster(
                imageUrl: widget.movie.getFullPosterPath(),
                width: double.infinity,
                height: 200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),

              // Gradient overlay to make text more readable
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // Movie type tag (Film)
              Positioned(top: 10, left: 10, child: MediaTag(label: 'Film')),

              // Add to watchlist button
              Positioned(
                top: 10,
                right: 60,
                child: ActionButton(
                  icon: _isInWatchlist ? Icons.check : Icons.add,
                  onPressed: _toggleWatchlist,
                  isLoading: _isLoadingWatchlist,
                  isActive: _isInWatchlist,
                  tooltip:
                      _isInWatchlist
                          ? 'Retirer de la watchlist'
                          : 'Ajouter à la watchlist',
                ),
              ),

              // Watched button
              Positioned(
                top: 10,
                right: 10,
                child: ActionButton(
                  icon: Icons.visibility,
                  onPressed: _toggleWatched,
                  isLoading: _isLoadingWatched,
                  isActive: _isWatched,
                  tooltip:
                      _isWatched ? 'Marquer comme non vu' : 'Marquer comme vu',
                ),
              ),

              // Title at the bottom of the image
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Text(
                  widget.movie.title,
                  style: const TextStyle(
                    color: Color(0xFFF8C13A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Color(0xFF16232E),
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Movie info section
          MediaInfoCard(
            title: widget.movie.title,
            rating: widget.movie.voteAverage,
            releaseDate: widget.movie.releaseDate,
            overview: widget.movie.overview,
          ),
        ],
      ),
    );
  }
}
