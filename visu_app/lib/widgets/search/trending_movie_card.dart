import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TrendingMovieCard extends StatelessWidget {

  const TrendingMovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  final dynamic movie;
  final Function(dynamic) onTap;

  @override
  Widget build(BuildContext context) {
    final String title = movie.title ?? 'Sans titre';
    final String imageUrl =
        movie.posterPath != null
            ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}'
            : '';
    final double rating = movie.voteAverage != null ? (movie.voteAverage / 2) : 0.0;

    return GestureDetector(
      onTap: () => onTap(movie),
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du film
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
                          child: const Icon(Icons.movie, color: Colors.white),
                        ),
              ),
            ),

            // Titre du film
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

            // Note du film
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
