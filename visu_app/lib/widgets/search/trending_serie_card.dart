import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '/visu.dart';

class TrendingSerieCard extends StatefulWidget {
  const TrendingSerieCard({
    super.key,
    required this.serie,
    required this.onTap,
  });

  final dynamic serie;
  final Function(dynamic) onTap;

  @override
  State<TrendingSerieCard> createState() => _TrendingSerieCardState();
}

class _TrendingSerieCardState extends State<TrendingSerieCard> {
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
      final serieId =
          widget.serie is Serie
              ? widget.serie.id
              : (widget.serie is Map ? widget.serie['id'] : 0);
      if (serieId == 0) return;

      final isInWatchlist = await _watchlistService.isInWatchlist(
        itemId: serieId,
        mediaType: MediaType.tv,
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

    final serieId =
        widget.serie is Serie
            ? widget.serie.id
            : (widget.serie is Map ? widget.serie['id'] : 0);
    final title =
        widget.serie is Serie
            ? widget.serie.title
            : (widget.serie is Map ? widget.serie['name'] : '');
    final posterPath =
        widget.serie is Serie
            ? widget.serie.imageUrl
            : (widget.serie is Map ? widget.serie['poster_path'] : '');

    if (serieId == 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _watchlistService.toggleWatchlist(
        itemId: serieId,
        mediaType: MediaType.tv,
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
        widget.serie is Serie
            ? widget.serie.title
            : (widget.serie is Map ? widget.serie['name'] : 'Sans titre');
    final String imageUrl =
        widget.serie is Serie
            ? widget.serie.imageUrl
            : (widget.serie is Map && widget.serie['poster_path'] != null
                ? 'https://image.tmdb.org/t/p/w200${widget.serie['poster_path']}'
                : '');
    final double rating =
        widget.serie is Serie
            ? widget.serie.rating
            : (widget.serie is Map && widget.serie['vote_average'] != null
                ? (widget.serie['vote_average'] as num).toDouble()
                : 0.0);

    return GestureDetector(
      onTap: () {
        if (widget.serie is Serie ||
            (widget.serie is Map && widget.serie['first_air_date'] != null)) {
          final int id =
              widget.serie is Serie ? widget.serie.id : widget.serie['id'];
          context.push('/series/detail/$id');
        } else if (widget.serie is Map &&
            widget.serie['release_date'] != null) {
          context.push('/movies/detail/${widget.serie['id']}');
        } else {
          widget.onTap(widget.serie);
        }
      },
      child: Stack(
        children: [
          Container(
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Serie image
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
                              child: const Icon(Icons.tv, color: Colors.white),
                            ),
                  ),
                ),

                // Series title
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

                // Series rating
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
