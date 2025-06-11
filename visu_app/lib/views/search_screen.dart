import 'dart:async';
import 'package:flutter/material.dart';
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
    _loadTrendingContent();
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
    } else {
      _performSearch();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _searchQuery = '';
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
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: const Text(
          'Recherche',
          style: TextStyle(color: Color(0xFFF8C13A)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppSearchBar(
              onSearch: _onSearchChanged,
              onClear: _clearSearch,
              hintText: 'Rechercher un film ou une série...',
              initialValue: _searchQuery,
            ),
          ),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_errorMessage != null) {
      return ErrorDisplay(message: _errorMessage!, onRetry: _performSearch);
    }

    if (_searchResults.isEmpty) {
      if (_searchQuery.isEmpty) {
        return _buildTrendingContent();
      } else {
        return EmptyStateView(
          title: 'Aucun résultat trouvé pour "$_searchQuery"',
          icon: Icons.sentiment_dissatisfied,
        );
      }
    }

    return SearchResultsList(
      results: _searchResults,
      onItemTap: _navigateToDetails,
    );
  }

  Widget _buildTrendingContent() {
    if (_isLoadingTrending) {
      return const LoadingIndicator();
    }

    if (_trendingErrorMessage != null) {
      return ErrorDisplay(
        message: _trendingErrorMessage!,
        onRetry: _loadTrendingContent,
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

          // Ajouter une marge en bas pour permettre un meilleur défilement
          const SizedBox(height: 100),
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
}
