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
  bool _isInWatchlist = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkWatchlistStatus();
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

  Future<void> _toggleWatchlist() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
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
          _isLoading = false;
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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.movie.getFullPosterPath(),
                    width: 120,
                    height: 160,
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

                // Movie information
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        Text(
                          widget.movie.title,
                          style: const TextStyle(
                            color: Color(0xFFF4F6F8),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Note
                        Row(
                          children: [
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
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Release date
                        Text(
                          'Sortie : ${_formatDate(widget.movie.releaseDate)}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Description
                        Text(
                          widget.movie.overview,
                          style: const TextStyle(
                            color: Color(0xFFF4F6F8),
                            fontSize: 12,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                  icon:
                      _isLoading
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
