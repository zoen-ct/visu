import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '/visu.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TMDbService _tmdbService = TMDbService();
  Timer? _debounce;
  bool _isLoading = false;
  bool _isLoadingTrending = false;
  String _searchQuery = '';
  List<SearchResult> _searchResults = [];
  List<dynamic> _trendingSeries = [];
  List<dynamic> _trendingMovies = [];
  String? _errorMessage;
  String? _trendingErrorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadTrendingContent();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadTrendingContent() async {
    setState(() {
      _isLoadingTrending = true;
      _trendingErrorMessage = null;
    });

    try {
      // Charger les séries tendances
      final trendingSeries = await _tmdbService.getTrendingSeries();

      // Charger les films tendances
      final trendingMovies = await _tmdbService.getTrendingMovies();

      if (mounted) {
        setState(() {
          _trendingSeries = trendingSeries;
          _trendingMovies = trendingMovies;
          _isLoadingTrending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _trendingErrorMessage = 'Erreur lors du chargement des tendances: $e';
          _isLoadingTrending = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchQuery = _searchController.text;
        _performSearch();
      } else {
        setState(() {
          _searchResults = [];
          _searchQuery = '';
        });
      }
    });
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _tmdbService.searchMulti(_searchQuery);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de la recherche. Veuillez réessayer.';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDetails(SearchResult result) {
    if (result.mediaType == MediaType.tv) {
      context.push('/series/detail/${result.id}');
    } else if (result.mediaType == MediaType.movie) {
      context.push('/movies/detail/${result.id}');
    }
  }

  void _navigateToSerieDetail(dynamic serie) {
    context.push('/series/detail/${serie.id}');
  }

  void _navigateToMovieDetail(dynamic movie) {
    final int id = movie['id'] ?? 0;
    context.push('/movies/detail/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16232E),
        title: const Text(
          'Recherche',
          style: TextStyle(color: Color(0xFFF8C13A)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un film ou une série...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF4F6F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF16232E)),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF16232E),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                            });
                          },
                        )
                        : null,
              ),
              style: const TextStyle(color: Color(0xFF16232E)),
              cursorColor: const Color(0xFF16232E),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF8C13A)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFF4F6F8), fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8C13A),
                foregroundColor: const Color(0xFF16232E),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      if (_searchQuery.isEmpty) {
        return _buildTrendingContent();
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sentiment_dissatisfied,
                color: Color(0xFFF8C13A),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun résultat trouvé pour "$_searchQuery"',
                style: const TextStyle(color: Color(0xFFF4F6F8), fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildSearchResultCard(result);
      },
    );
  }

  Widget _buildTrendingContent() {
    if (_isLoadingTrending) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF8C13A)),
        ),
      );
    }

    if (_trendingErrorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _trendingErrorMessage!,
              style: const TextStyle(color: Color(0xFFF4F6F8), fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTrendingContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8C13A),
                foregroundColor: const Color(0xFF16232E),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        // Séries tendances
        if (_trendingSeries.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'Séries tendances',
              style: TextStyle(
                color: Color(0xFFF8C13A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _trendingSeries.length,
              itemBuilder: (context, index) {
                final serie = _trendingSeries[index];
                return _buildTrendingSerieCard(serie);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Films tendances
        if (_trendingMovies.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'Films tendances',
              style: TextStyle(
                color: Color(0xFFF8C13A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _trendingMovies.length,
              itemBuilder: (context, index) {
                final movie = _trendingMovies[index];
                return _buildTrendingMovieCard(movie);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrendingSerieCard(dynamic serie) {
    return TrendingSerieCard(serie: serie, onTap: _navigateToSerieDetail);
  }

  Widget _buildTrendingMovieCard(dynamic movie) {
    return TrendingMovieCard(movie: movie, onTap: _navigateToMovieDetail);
  }

  Widget _buildSearchResultCard(SearchResult result) {
    if (result.mediaType == MediaType.movie) {
      return MovieCard(movie: result, onTap: () => _navigateToDetails(result));
    } else if (result.mediaType == MediaType.tv) {
      // Convertir le SearchResult en Serie pour l'utiliser avec SerieCard
      final serie = Serie(
        id: result.id,
        title: result.title,
        imageUrl: result.getFullPosterPath(),
        rating: result.voteAverage,
        releaseDate: result.releaseDate ?? '',
        description: result.overview,
        genres: [],
      );

      return SerieCard(serie: serie, onTap: () => _navigateToDetails(result));
    } else {
      // Pour les autres types (personnes, etc.)
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: const Color(0xFF1D2F3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _navigateToDetails(result),
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
}
