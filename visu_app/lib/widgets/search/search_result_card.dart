import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/visu.dart';

class SearchResultCard extends StatelessWidget {

  const SearchResultCard({
    super.key,
    required this.result,
    required this.onTap,
  });
  
  final SearchResult result;
  final Function(SearchResult) onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1D2F3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(result),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            CachedNetworkImage(
              imageUrl: result.getFullPosterPath(),
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    width: 100,
                    height: 150,
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
                  (context, url, error) => Container(
                    width: 100,
                    height: 150,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                    ),
                  ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      result.title,
                      style: const TextStyle(
                        color: Color(0xFFF4F6F8),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Type and year
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8C13A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            result.getMediaTypeDisplay(),
                            style: const TextStyle(
                              color: Color(0xFF16232E),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (result.getYearFromReleaseDate().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            result.getYearFromReleaseDate(),
                            style: const TextStyle(
                              color: Color(0xFFF4F6F8),
                              fontSize: 12,
                            ),
                          ),
                        ],

                        const SizedBox(width: 8),

                        // Vote average
                        if (result.voteAverage > 0) ...[
                          const Icon(
                            Icons.star,
                            color: Color(0xFFF8C13A),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            result.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFFF4F6F8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      result.overview,
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
            ),
          ],
        ),
      ),
    );
  }
}
