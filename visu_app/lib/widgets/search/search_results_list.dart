import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visu/visu.dart';
/// A widget to display media search results
class SearchResultsList extends StatelessWidget {
  const SearchResultsList({
    super.key,
    required this.results,
    this.onItemTap,
    this.loadingMore = false,
    this.onLoadMore,
    this.emptyMessage = 'Aucun résultat trouvé',
  });

  final List<SearchResult> results;
  final Function(SearchResult)? onItemTap;
  final bool loadingMore;
  final VoidCallback? onLoadMore;
  final String emptyMessage;

  void _handleItemTap(BuildContext context, SearchResult result) {
    if (onItemTap != null) {
      onItemTap!(result);
    } else {
      if (result.mediaType == MediaType.movie) {
        context.push('/movies/detail/${result.id}');
      } else if (result.mediaType == MediaType.tv) {
        context.push('/series/detail/${result.id}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return EmptyStateView(title: emptyMessage, icon: Icons.search_off);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            !loadingMore &&
            onLoadMore != null) {
          onLoadMore!();
          return true;
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        itemCount: results.length + (loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == results.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFF8C13A)),
              ),
            );
          }

          final result = results[index];
          if (result.mediaType == MediaType.movie) {
            return MovieCard(
              movie: result,
              onTap: () => _handleItemTap(context, result),
            );
          } else if (result.mediaType == MediaType.tv) {
            final serie = Serie(
              id: result.id,
              title: result.title,
              description: result.overview,
              imageUrl: result.getFullPosterPath(),
              rating: result.voteAverage,
              releaseDate: result.releaseDate ?? '',
              genres:
                  [],
            );

            return SerieCard(
              serie: serie,
              onTap: () => _handleItemTap(context, result),
            );
          }

          // Fallback for other types (unlikely but safe)
          return ListTile(
            title: Text(
              result.title,
              style: const TextStyle(color: Color(0xFFF4F6F8)),
            ),
            subtitle: Text(
              result.getMediaTypeDisplay(),
              style: TextStyle(color: Colors.grey[400]),
            ),
            onTap: () => _handleItemTap(context, result),
          );
        },
      ),
    );
  }
}
