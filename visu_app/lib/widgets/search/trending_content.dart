import 'package:flutter/material.dart';
import 'trending_serie_card.dart';
import 'trending_movie_card.dart';

class TrendingContent extends StatelessWidget {

  const TrendingContent({
    super.key,
    required this.trendingSeries,
    required this.trendingMovies,
    required this.onSerieCardTap,
    required this.onMovieCardTap,
    this.isLoading = false,
    this.errorMessage,
  });
  
  final List<dynamic> trendingSeries;
  final List<dynamic> trendingMovies;
  final Function(dynamic) onSerieCardTap;
  final Function(dynamic) onMovieCardTap;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF8C13A)),
        ),
      );
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Séries tendances
        if (trendingSeries.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              'Séries tendances',
              style: TextStyle(
                color: Color(0xFFF8C13A),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: trendingSeries.length,
              itemBuilder: (context, index) {
                final serie = trendingSeries[index];
                return TrendingSerieCard(serie: serie, onTap: onSerieCardTap);
              },
            ),
          ),
        ],

        // Films tendances
        if (trendingMovies.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              'Films tendances',
              style: TextStyle(
                color: Color(0xFFF8C13A),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: trendingMovies.length,
              itemBuilder: (context, index) {
                final movie = trendingMovies[index];
                return TrendingMovieCard(movie: movie, onTap: onMovieCardTap);
              },
            ),
          ),
        ],

        if (trendingSeries.isEmpty && trendingMovies.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 32.0),
              child: Text(
                'Aucun contenu tendance trouvé',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
