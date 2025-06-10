import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '/visu.dart';

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

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Date inconnue';
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return dateStr;
    } catch (e) {
      return 'Date inconnue';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1D2F3E),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image and buttons
            Stack(
              children: [
                // Movie image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.movie.getFullPosterPath(),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFF8C13A),
                            ),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.error, color: Colors.red),
                        ),
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
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8C13A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Film',
                      style: TextStyle(
                        color: Color(0xFF16232E),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                // Add to watchlist button
                Positioned(
                  top: 10,
                  right: 60,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16232E),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon:
                          _isLoadingWatchlist
                              ? const SizedBox(
                                width: 18,
                                height: 18,
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
                              ),
                      onPressed: _toggleWatchlist,
                      tooltip:
                          _isInWatchlist
                              ? 'Retirer de la watchlist'
                              : 'Ajouter à la watchlist',
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // Watched button
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          _isWatched
                              ? const Color(0xFFF8C13A)
                              : const Color(0xFF16232E),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon:
                          _isLoadingWatched
                              ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color:
                                      _isWatched
                                          ? const Color(0xFF16232E)
                                          : const Color(0xFFF8C13A),
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(
                                Icons.visibility,
                                color:
                                    _isWatched
                                        ? const Color(0xFF16232E)
                                        : Colors.white,
                              ),
                      onPressed: _toggleWatched,
                      tooltip:
                          _isWatched
                              ? 'Marquer comme non vu'
                              : 'Marquer comme vu',
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                    ),
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row with rating and release date
                  Row(
                    children: [
                      // Rating
                      const Icon(
                        Icons.star,
                        color: Color(0xFFF8C13A),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.movie.voteAverage}/10',
                        style: const TextStyle(
                          color: Color(0xFFF4F6F8),
                          fontSize: 14,
                        ),
                      ),

                      const Spacer(),

                      // Release date
                      Text(
                        'Sortie : ${_formatDate(widget.movie.releaseDate)}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    widget.movie.overview,
                    style: const TextStyle(
                      color: Color(0xFFF4F6F8),
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
