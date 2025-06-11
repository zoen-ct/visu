import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visu/visu.dart';

/// Widget to display a trending series card in a horizontal carousel
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
    String imageUrl;
    String title;

    if (serie is Serie) {
      imageUrl = serie.imageUrl;
      title = serie.title;
    } else {
      final String posterPath = serie.posterPath ?? '';
      imageUrl =
          '${ApiConfig.tmdbImageBaseUrl}/${ApiConfig.posterSize}/$posterPath';
      title = serie.name ?? 'Sans titre';
    }

    return GestureDetector(
      onTap: () => onTap(serie),
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
