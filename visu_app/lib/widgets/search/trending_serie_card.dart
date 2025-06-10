import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '/visu.dart';

class TrendingSerieCard extends StatelessWidget {
  const TrendingSerieCard({
    super.key,
    required this.serie,
    required this.onTap,
  });

  final dynamic serie;
  final Function(dynamic) onTap;

  @override
  Widget build(BuildContext context) {
    final String title = serie.name ?? 'Sans titre';
    final String imageUrl =
        serie.posterPath != null
            ? 'https://image.tmdb.org/t/p/w200${serie.posterPath}'
            : '';
    final double rating =
        serie.voteAverage != null ? (serie.voteAverage / 2) : 0.0;

    return GestureDetector(
      onTap: () {
        // Navigation vers les détails de la série ou du film
        if (serie is Serie ||
            (serie is Map && serie['first_air_date'] != null)) {
          // C'est une série
          context.push('/series/detail/${serie.id}');
        } else if (serie is Map && serie['release_date'] != null) {
          // C'est un film
          context.push('/movies/detail/${serie.id}');
        } else {
          // Fallback - utiliser la fonction onTap fournie
          onTap(serie);
        }
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la série
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
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

            // Titre de la série
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

            // Note de la série
            if (rating > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFF8C13A), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
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
