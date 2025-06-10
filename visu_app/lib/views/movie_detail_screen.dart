import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '/visu.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});
  final int movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late TMDbService _tmdbService;
  late SupabaseFavoritesService _favoritesService;
  late SupabaseHistoryService _historyService;
  late SupabaseWatchlistService _watchlistService;

  Map<String, dynamic>? _movieDetails;
  bool _isLoading = true;
  String? _errorMessage;

  bool _isFavorite = false;
  bool _isWatched = false;
  bool _isInWatchlist = false;
  bool _isFavoriteLoading = false;
  bool _isWatchedLoading = false;
  bool _isWatchlistLoading = false;

  @override
  void initState() {
    super.initState();
    _tmdbService = TMDbService();
    _favoritesService = SupabaseFavoritesService();
    _historyService = SupabaseHistoryService();
    _watchlistService = SupabaseWatchlistService();
    _loadMovieDetails();
    _checkFavoriteStatus();
    _checkWatchedStatus();
    _checkWatchlistStatus();
  }

  Future<void> _loadMovieDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final detailsJson = await _tmdbService.getMovieDetails(widget.movieId);
      final creditsJson = await _tmdbService.getCredits(
        widget.movieId,
        mediaType: MediaType.movie,
      );

      final Map<String, dynamic> details = {
        ...detailsJson,
        'credits': creditsJson,
      };

      if (mounted) {
        setState(() {
          _movieDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des détails du film';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFavorite = await _favoritesService.isFavorite(
        itemId: widget.movieId,
        mediaType: MediaType.movie,
      );

      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification des favoris: $e');
    }
  }

  Future<void> _checkWatchedStatus() async {
    try {
      final isWatched = await _historyService.isWatched(
        itemId: widget.movieId,
        mediaType: MediaType.movie,
      );

      if (mounted) {
        setState(() {
          _isWatched = isWatched;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification de l\'historique: $e');
    }
  }

  Future<void> _checkWatchlistStatus() async {
    try {
      final isInWatchlist = await _watchlistService.isInWatchlist(
        itemId: widget.movieId,
        mediaType: MediaType.movie,
      );

      if (mounted) {
        setState(() {
          _isInWatchlist = isInWatchlist;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la watchlist: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriteLoading || _movieDetails == null) return;

    setState(() {
      _isFavoriteLoading = true;
    });

    try {
      bool success;
      if (_isFavorite) {
        success = await _favoritesService.removeFromFavorites(
          itemId: widget.movieId,
          mediaType: MediaType.movie,
        );
      } else {
        success = await _favoritesService.addToFavorites(
          itemId: widget.movieId,
          mediaType: MediaType.movie,
          title: _movieDetails!['title'],
          posterPath: _movieDetails!['poster_path'],
        );
      }

      if (mounted && success) {
        setState(() {
          _isFavorite = !_isFavorite;
          _isFavoriteLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? 'Ajouté aux favoris' : 'Retiré des favoris',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF16232E),
          ),
        );
      } else if (mounted) {
        setState(() {
          _isFavoriteLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFavoriteLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleWatched() async {
    if (_isWatchedLoading || _movieDetails == null) return;

    setState(() {
      _isWatchedLoading = true;
    });

    try {
      bool success;
      if (_isWatched) {
        success = await _historyService.markAsWatched(
          itemId: widget.movieId,
          mediaType: MediaType.movie,
          watched: false,
        );
      } else {
        success = await _historyService.markAsWatched(
          itemId: widget.movieId,
          mediaType: MediaType.movie,
          title: _movieDetails!['title'],
          posterPath: _movieDetails!['poster_path'],
          watched: true,
        );
      }

      if (mounted && success) {
        setState(() {
          _isWatched = !_isWatched;
          _isWatchedLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isWatched ? 'Marqué comme vu' : 'Marqué comme non vu',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF16232E),
          ),
        );
      } else if (mounted) {
        setState(() {
          _isWatchedLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isWatchedLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleWatchlist() async {
    if (_isWatchlistLoading || _movieDetails == null) return;

    setState(() {
      _isWatchlistLoading = true;
    });

    try {
      bool success = await _watchlistService.toggleWatchlist(
        itemId: widget.movieId,
        mediaType: MediaType.movie,
        title: _movieDetails!['title'],
        posterPath: _movieDetails!['poster_path'],
        addToWatchlist: !_isInWatchlist,
      );

      if (mounted && success) {
        setState(() {
          _isInWatchlist = !_isInWatchlist;
          _isWatchlistLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isInWatchlist
                  ? 'Ajouté à la watchlist'
                  : 'Retiré de la watchlist',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF16232E),
          ),
        );
      } else if (mounted) {
        setState(() {
          _isWatchlistLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isWatchlistLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateStr);
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(date);
    } catch (e) {
      return 'Date inconnue';
    }
  }

  String _formatRuntime(int? runtime) {
    if (runtime == null) return 'Durée inconnue';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFF4F6F8),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard({
    required String name,
    required String role,
    required String? profilePath,
  }) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                profilePath != null && profilePath.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: 'https://image.tmdb.org/t/p/w185$profilePath',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFF8C13A),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.person,
                              color: Colors.white54,
                            ),
                          ),
                    )
                    : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[800],
                      child: const Icon(Icons.person, color: Colors.white54),
                    ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFFF4F6F8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            role,
            style: TextStyle(color: Colors.grey[400], fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      // Ajout des boutons flottants pour watchlist et vu
      floatingActionButton:
          _movieDetails == null
              ? null
              : Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bouton pour ajouter à la watchlist
                    FloatingActionButton(
                      heroTag: 'watchlist',
                      onPressed: _toggleWatchlist,
                      backgroundColor: const Color(0xFF1D2F3E),
                      shape: const CircleBorder(),
                      child:
                          _isWatchlistLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Color(0xFFF8C13A),
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(
                                _isInWatchlist ? Icons.check : Icons.add,
                                color: const Color(0xFFF8C13A),
                                size: 30,
                              ),
                    ),
                    const SizedBox(width: 20),
                    // Bouton pour marquer comme vu/favoris
                    FloatingActionButton(
                      heroTag: 'favorite',
                      onPressed: _toggleFavorite,
                      backgroundColor: const Color(0xFFF8C13A),
                      shape: const CircleBorder(),
                      child:
                          _isFavoriteLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.black,
                                size: 30,
                              ),
                    ),
                  ],
                ),
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFF8C13A)),
              )
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFF4F6F8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadMovieDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8C13A),
                        foregroundColor: const Color(0xFF16232E),
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : _movieDetails == null
              ? const Center(
                child: Text(
                  'Aucune information disponible',
                  style: TextStyle(color: Color(0xFFF4F6F8)),
                ),
              )
              : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    backgroundColor: const Color(0xFF16232E),
                    flexibleSpace: FlexibleSpaceBar(
                      background:
                          _movieDetails!['backdrop_path'] != null
                              ? CachedNetworkImage(
                                imageUrl:
                                    'https://image.tmdb.org/t/p/w1280${_movieDetails!['backdrop_path']}',
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Container(
                                      color: const Color(0xFF16232E),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFFF8C13A),
                                        ),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Container(
                                      color: const Color(0xFF16232E),
                                      child: const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                    ),
                              )
                              : Container(color: const Color(0xFF16232E)),
                      title: Text(
                        _movieDetails!['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    iconTheme: const IconThemeData(color: Color(0xFFF4F6F8)),
                    actions: [
                      IconButton(
                        icon:
                            _isFavoriteLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFF8C13A),
                                    strokeWidth: 2,
                                  ),
                                )
                                : Icon(
                                  _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      _isFavorite ? Colors.red : Colors.white,
                                ),
                        onPressed: _toggleFavorite,
                        tooltip:
                            _isFavorite
                                ? 'Retirer des favoris'
                                : 'Ajouter aux favoris',
                      ),
                      // Bouton Vu
                      IconButton(
                        icon:
                            _isWatchedLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFF8C13A),
                                    strokeWidth: 2,
                                  ),
                                )
                                : Icon(
                                  _isWatched
                                      ? Icons.visibility
                                      : Icons.visibility_outlined,
                                  color:
                                      _isWatched
                                          ? const Color(0xFFF8C13A)
                                          : Colors.white,
                                ),
                        onPressed: _toggleWatched,
                        tooltip:
                            _isWatched
                                ? 'Marquer comme non vu'
                                : 'Marquer comme vu',
                      ),
                    ],
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_movieDetails!['poster_path'] != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        'https://image.tmdb.org/t/p/w500${_movieDetails!['poster_path']}',
                                    width: 120,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => Container(
                                          color: Colors.grey[800],
                                          width: 120,
                                          height: 180,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFFF8C13A),
                                            ),
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Container(
                                          color: Colors.grey[800],
                                          width: 120,
                                          height: 180,
                                          child: const Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          ),
                                        ),
                                  ),
                                ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Titre
                                    Text(
                                      _movieDetails!['title'],
                                      style: const TextStyle(
                                        color: Color(0xFFF4F6F8),
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    if (_movieDetails!['release_date'] !=
                                        null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '(${_movieDetails!['release_date'].toString().substring(0, 4)})',
                                        style: TextStyle(
                                          color: Colors.grey[300],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        RatingBar.builder(
                                          initialRating:
                                              (_movieDetails!['vote_average']
                                                  as num) /
                                              2,
                                          minRating: 0,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 20,
                                          ignoreGestures: true,
                                          itemBuilder:
                                              (context, _) => const Icon(
                                                Icons.star,
                                                color: Color(0xFFF8C13A),
                                              ),
                                          onRatingUpdate: (_) {},
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${(_movieDetails!['vote_average'] as num).toStringAsFixed(1)}/10',
                                          style: TextStyle(
                                            color: Colors.grey[300],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children:
                                          (_movieDetails!['genres']
                                                  as List<dynamic>)
                                              .map((genre) {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF1D2F3E,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFFF8C13A,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    genre['name'],
                                                    style: const TextStyle(
                                                      color: Color(0xFFF4F6F8),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                );
                                              })
                                              .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Synopsis',
                            style: TextStyle(
                              color: Color(0xFFF8C13A),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _movieDetails!['overview'] != null &&
                                    _movieDetails!['overview']
                                        .toString()
                                        .isNotEmpty
                                ? _movieDetails!['overview']
                                : 'Aucun synopsis disponible',
                            style: const TextStyle(
                              color: Color(0xFFF4F6F8),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Informations',
                            style: TextStyle(
                              color: Color(0xFFF8C13A),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Date de sortie',
                            _formatDate(_movieDetails!['release_date']),
                          ),
                          _buildInfoRow(
                            'Durée',
                            _formatRuntime(_movieDetails!['runtime']),
                          ),
                          if (_movieDetails!['budget'] != null &&
                              (_movieDetails!['budget'] as num) > 0)
                            _buildInfoRow(
                              'Budget',
                              '\$${(_movieDetails!['budget'] as num).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')}',
                            ),
                          if (_movieDetails!['revenue'] != null &&
                              (_movieDetails!['revenue'] as num) > 0)
                            _buildInfoRow(
                              'Recettes',
                              '\$${(_movieDetails!['revenue'] as num).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')}',
                            ),
                          if (_movieDetails!['status'] != null)
                            _buildInfoRow('Statut', _movieDetails!['status']),

                          const SizedBox(height: 24),

                          if (_movieDetails!['credits'] != null &&
                              (_movieDetails!['credits']['cast']
                                      as List<dynamic>)
                                  .isNotEmpty) ...[
                            const Text(
                              'Casting',
                              style: TextStyle(
                                color: Color(0xFFF8C13A),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 160,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    (_movieDetails!['credits']['cast']
                                                    as List<dynamic>)
                                                .length >
                                            10
                                        ? 10
                                        : (_movieDetails!['credits']['cast']
                                                as List<dynamic>)
                                            .length,
                                itemBuilder: (context, index) {
                                  final actor =
                                      (_movieDetails!['credits']['cast']
                                          as List<dynamic>)[index];
                                  return _buildPersonCard(
                                    name: actor['name'],
                                    role: actor['character'] ?? 'Acteur',
                                    profilePath: actor['profile_path'],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          if (_movieDetails!['credits'] != null &&
                              (_movieDetails!['credits']['crew']
                                      as List<dynamic>)
                                  .isNotEmpty) ...[
                            const Text(
                              'Équipe technique',
                              style: TextStyle(
                                color: Color(0xFFF8C13A),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 160,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    (_movieDetails!['credits']['crew']
                                            as List<dynamic>)
                                        .where(
                                          (crew) =>
                                              crew['job'] == 'Director' ||
                                              crew['job'] == 'Producer' ||
                                              crew['job'] == 'Writer',
                                        )
                                        .toList()
                                        .length,
                                itemBuilder: (context, index) {
                                  final crew =
                                      (_movieDetails!['credits']['crew']
                                              as List<dynamic>)
                                          .where(
                                            (crew) =>
                                                crew['job'] == 'Director' ||
                                                crew['job'] == 'Producer' ||
                                                crew['job'] == 'Writer',
                                          )
                                          .toList()[index];
                                  return _buildPersonCard(
                                    name: crew['name'],
                                    role: crew['job'],
                                    profilePath: crew['profile_path'],
                                  );
                                },
                              ),
                            ),
                          ],

                          // Ajout d'une marge en bas pour permettre un meilleur défilement
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
