import 'package:flutter/material.dart';
import 'package:visu/visu.dart';

/// Widget representing a series card with its features
class SerieCard extends StatefulWidget {
  const SerieCard({super.key, required this.serie, required this.onTap});

  final Serie serie;
  final VoidCallback onTap;

  @override
  State<SerieCard> createState() => _SerieCardState();
}

class _SerieCardState extends State<SerieCard> {
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
        itemId: widget.serie.id,
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

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _watchlistService.toggleWatchlist(
        itemId: widget.serie.id,
        mediaType: MediaType.tv,
        title: widget.serie.title,
        posterPath: widget.serie.imageUrl.split('/').last,
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

  @override
  Widget build(BuildContext context) {
    return MediaCard(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Series image
              MediaPoster(
                imageUrl: widget.serie.imageUrl,
                width: 120,
                height: 160,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),

              // Series information
              Expanded(
                child: MediaInfoCard(
                  title: widget.serie.title,
                  rating: widget.serie.rating,
                  releaseDate: widget.serie.releaseDate,
                  genres: widget.serie.genres,
                ),
              ),
            ],
          ),

          // Add to watchlist button
          Positioned(
            top: 5,
            right: 5,
            child: ActionButton(
              icon: _isInWatchlist ? Icons.check : Icons.add,
              onPressed: _toggleWatchlist,
              isLoading: _isLoading,
              isActive: _isInWatchlist,
              tooltip:
                  _isInWatchlist
                      ? 'Retirer de la watchlist'
                      : 'Ajouter à la watchlist',
              size: 36,
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
