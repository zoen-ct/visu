import 'package:flutter/material.dart';

/// A widget to display basic information about a media (movie or TV show)
class MediaInfoCard extends StatelessWidget {
  const MediaInfoCard({
    super.key,
    required this.title,
    this.rating,
    this.releaseDate,
    this.overview,
    this.genres = const [],
  });

  final String title;
  final double? rating;
  final String? releaseDate;
  final String? overview;
  final List<String> genres;

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
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Title
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFF4F6F8),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Row with rating and release date
          Row(
            children: [
              // Rating
              if (rating != null) ...[
                const Icon(Icons.star, color: Color(0xFFF8C13A), size: 18),
                const SizedBox(width: 4),
                Text(
                  '$rating/10',
                  style: const TextStyle(
                    color: Color(0xFFF4F6F8),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
              ],

              // Release date
              if (releaseDate != null)
                Text(
                  'Sortie : ${_formatDate(releaseDate)}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
            ],
          ),

          if (overview != null) ...[
            const SizedBox(height: 8),
            // Overview
            Text(
              overview!,
              style: const TextStyle(color: Color(0xFFF4F6F8), fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (genres.isNotEmpty) ...[
            const SizedBox(height: 8),
            // Genres
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children:
                  genres.take(3).map((genre) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16232E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        genre,
                        style: const TextStyle(
                          color: Color(0xFFF4F6F8),
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
