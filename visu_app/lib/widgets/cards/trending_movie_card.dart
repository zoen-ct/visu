import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visu/visu.dart';

/// Widget to display a trending movie card in a horizontal carousel
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
    final String posterPath = movie['poster_path'] ?? '';
    final String imageUrl =
        '${ApiConfig.tmdbImageBaseUrl}/${ApiConfig.posterSize}/$posterPath';
    final String title = movie['title'] ?? 'Sans titre';

    return GestureDetector(
      onTap: () => onTap(movie),
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 160,
                width: 120,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: const Color(0xFF1D2F3E),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF8C13A),
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: const Color(0xFF1D2F3E),
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFF4F6F8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
