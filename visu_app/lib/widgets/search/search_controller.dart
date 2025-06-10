import 'dart:async';
import 'package:flutter/material.dart';

import '/visu.dart';

class SearchController extends ChangeNotifier {

  SearchController({required this.onStateChanged}) {
    textController.addListener(_onSearchChanged);
    loadTrendingContent();
  }
  final TMDbService _tmdbService = TMDbService();
  final TextEditingController textController = TextEditingController();
  Timer? _debounce;

  bool isLoading = false;
  bool isLoadingTrending = false;
  String searchQuery = '';
  List<SearchResult> searchResults = [];
  List<dynamic> trendingSeries = [];
  List<dynamic> trendingMovies = [];
  String? errorMessage;
  String? trendingErrorMessage;

  final Function() onStateChanged;

  @override
  void dispose() {
    textController.removeListener(_onSearchChanged);
    textController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (textController.text.isNotEmpty) {
        searchQuery = textController.text;
        performSearch();
      } else {
        searchResults = [];
        searchQuery = '';
        onStateChanged();
      }
    });
  }

  Future<void> loadTrendingContent() async {
    isLoadingTrending = true;
    trendingErrorMessage = null;
    onStateChanged();

    try {
      // Charger les séries tendances
      final series = await _tmdbService.getTrendingSeries();

      // Charger les films tendances
      final movies = await _tmdbService.getTrendingMovies();

      trendingSeries = series;
      trendingMovies = movies;
      isLoadingTrending = false;
      onStateChanged();
    } catch (e) {
      trendingErrorMessage = 'Erreur lors du chargement des tendances: $e';
      isLoadingTrending = false;
      onStateChanged();
    }
  }

  Future<void> performSearch() async {
    if (searchQuery.isEmpty) return;

    isLoading = true;
    errorMessage = null;
    onStateChanged();

    try {
      final results = await _tmdbService.searchMulti(searchQuery);

      searchResults = results;
      isLoading = false;
      onStateChanged();
    } catch (error) {
      errorMessage = 'Erreur lors de la recherche. Veuillez réessayer.';
      isLoading = false;
      onStateChanged();
    }
  }

  void clearSearch() {
    textController.clear();
    searchResults = [];
    searchQuery = '';
    onStateChanged();
  }
}
