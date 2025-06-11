import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '/visu.dart';

class TrendingMovieCard extends StatefulWidget {
  const TrendingMovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  final dynamic movie;
  final Function(dynamic) onTap;

  @override
  State<TrendingMovieCard> createState() => _TrendingMovieCardState();
}

class _TrendingMovieCardState extends State<TrendingMovieCard> {
  final SupabaseWatchlistService _watchlistService = SupabaseWatchlistService();
  bool _isInWatchlist = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkWatchlistStatus();
  }

  Future<void> _checkWatchlistStatus() async {
    try {
      final movieId = widget.movie is Map ? widget.movie['id'] : 0;
      if (movieId == 0) return;

      final isInWatchlist = await _watchlistService.isInWatchlist(
        itemId: movieId,
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

  Future<void> _toggleWatchlist() async {
    if (_isLoading) return;

    final movieId = widget.movie is Map ? widget.movie['id'] : 0;
    final title = widget.movie is Map ? widget.movie['title'] : '';
    final posterPath = widget.movie is Map ? widget.movie['poster_path'] : '';

    if (movieId == 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _watchlistService.toggleWatchlist(
        itemId: movieId,
        mediaType: MediaType.movie,
        title: title,
        posterPath: posterPath,
        addToWatchlist: !_isInWatchlist,
      );

      if (mounted && success) {
        setState(() {
          _isInWatchlist = !_isInWatchlist;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.movie is SearchResult
            ? widget.movie.title
            : (widget.movie is Map ? widget.movie['title'] : 'Sans titre');
    final String imageUrl =
        widget.movie is SearchResult
            ? widget.movie.getFullPosterPath()
            : (widget.movie is Map && widget.movie['poster_path'] != null
                ? 'https://image.tmdb.org/t/p/w200${widget.movie['poster_path']}'
                : '');
    final double rating =
        widget.movie is SearchResult
            ? widget.movie.voteAverage / 2
            : (widget.movie is Map && widget.movie['vote_average'] != null
                ? (widget.movie['vote_average'] as num).toDouble() / 2
                : 0.0);

    return GestureDetector(
      onTap: () => widget.onTap(widget.movie),
      child: Stack(
        children: [
          Container(
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie image
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              width: 120,
                              placeholder:
                                  (_, __) => Container(
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFFF8C13A),
                                            ),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (_, __, ___) => Container(
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.error,
                                      color: Colors.white,
                                    ),
                                  ),
                            )
                            : Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.movie,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),

                // Movie title
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Movie rating
                if (rating > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFF8C13A),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Add to watchlist button
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16232E).withOpacity(0.7),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4),
              ),
              child: IconButton(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: Color(0xFFF8C13A),
                            strokeWidth: 2,
                          ),
                        )
                        : Icon(
                          _isInWatchlist ? Icons.check : Icons.add,
                          color:
                              _isInWatchlist
                                  ? const Color(0xFFF8C13A)
                                  : Colors.white,
                          size: 18,
                        ),
                onPressed: _toggleWatchlist,
                tooltip:
                    _isInWatchlist
                        ? 'Retirer de la watchlist'
                        : 'Ajouter à la watchlist',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
