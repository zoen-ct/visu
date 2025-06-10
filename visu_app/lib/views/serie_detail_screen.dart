import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '/visu.dart';

class SerieDetailScreen extends StatefulWidget {
  const SerieDetailScreen({super.key, required this.serieId});
  final int serieId;

  @override
  State<SerieDetailScreen> createState() => _SerieDetailScreenState();
}

class _SerieDetailScreenState extends State<SerieDetailScreen> {
  late TMDbService _tmdbService;
  late SupabaseFavoritesService _favoritesService;
  late SupabaseHistoryService _historyService;
  late SupabaseWatchlistService _watchlistService;

  TvShowDetails? _tvShowDetails;
  bool _isLoading = true;
  String? _errorMessage;

  bool _isFavorite = false;
  bool _isInWatchlist = false;
  bool _isWatched = false;
  bool _isFavoriteLoading = false;
  bool _isWatchlistLoading = false;
  bool _isWatchedLoading = false;

  @override
  void initState() {
    super.initState();
    _tmdbService = TMDbService();
    _favoritesService = SupabaseFavoritesService();
    _historyService = SupabaseHistoryService();
    _watchlistService = SupabaseWatchlistService();
    _loadTvShowDetails();
    _checkFavoriteStatus();
    _checkWatchlistStatus();
    _checkWatchedStatus();
  }

  Future<void> _loadTvShowDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final detailsJson = await _tmdbService.getTvShowDetails(widget.serieId);

      final details = detailsJson;

      if (mounted) {
        setState(() {
          _tvShowDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Erreur lors du chargement des détails de la série $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFavorite = await _favoritesService.isFavorite(
        itemId: widget.serieId,
        mediaType: MediaType.tv,
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
        itemId: widget.serieId,
        mediaType: MediaType.tv,
      );

      if (mounted) {
        setState(() {
          _isWatched = isWatched;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification du statut vu: $e');
    }
  }

  Future<void> _checkWatchlistStatus() async {
    try {
      final isInWatchlist = await _watchlistService.isInWatchlist(
        itemId: widget.serieId,
        mediaType: MediaType.tv,
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
    if (_isFavoriteLoading || _tvShowDetails == null) return;

    setState(() {
      _isFavoriteLoading = true;
    });

    try {
      bool success;
      if (_isFavorite) {
        success = await _favoritesService.removeFromFavorites(
          itemId: widget.serieId,
          mediaType: MediaType.tv,
        );
      } else {
        success = await _favoritesService.addToFavorites(
          itemId: widget.serieId,
          mediaType: MediaType.tv,
          title: _tvShowDetails!.name,
          posterPath: _tvShowDetails!.posterPath,
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

  Future<void> _toggleWatchlist() async {
    if (_isWatchlistLoading || _tvShowDetails == null) return;

    setState(() {
      _isWatchlistLoading = true;
    });

    try {
      bool success = await _watchlistService.toggleWatchlist(
        itemId: widget.serieId,
        mediaType: MediaType.tv,
        title: _tvShowDetails!.name,
        posterPath: _tvShowDetails!.posterPath,
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

  Future<void> _toggleWatched() async {
    if (_isWatchedLoading || _tvShowDetails == null) return;

    setState(() {
      _isWatchedLoading = true;
    });

    try {
      bool success;
      if (_isWatched) {
        success = await _historyService.markAsWatched(
          itemId: widget.serieId,
          mediaType: MediaType.tv,
          watched: false,
        );
      } else {
        success = await _historyService.markAsWatched(
          itemId: widget.serieId,
          mediaType: MediaType.tv,
          title: _tvShowDetails!.name,
          posterPath: _tvShowDetails!.posterPath,
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

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateStr);
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(date);
    } catch (e) {
      return 'Date inconnue';
    }
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
    required String profilePath,
  }) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                profilePath.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: 'https://image.tmdb.org/t/p/w185${profilePath}',
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

  Widget _buildSeasons() {
    if (_tvShowDetails == null || _tvShowDetails!.seasons.isEmpty) {
      return const Center(
        child: Text(
          'Aucune saison disponible',
          style: TextStyle(color: Color(0xFFF4F6F8)),
        ),
      );
    }

    final seasons =
        _tvShowDetails!.seasons.where((s) => s.seasonNumber > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saisons',
          style: TextStyle(
            color: Color(0xFFF8C13A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: seasons.length,
          itemBuilder: (context, index) {
            final season = seasons[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: const Color(0xFF1D2F3E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                collapsedIconColor: const Color(0xFFF8C13A),
                iconColor: const Color(0xFFF8C13A),
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Row(
                  children: [
                    if (season.posterPath.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://image.tmdb.org/t/p/w185${season.posterPath}',
                          width: 60,
                          height: 90,
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
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            season.name,
                            style: const TextStyle(
                              color: Color(0xFFF4F6F8),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${season.episodeCount} épisodes · ${_formatDate(season.airDate)}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                children: [
                  if (season.overview.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        season.overview,
                        style: const TextStyle(
                          color: Color(0xFFF4F6F8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  ElevatedButton(
                    onPressed: () => _loadEpisodes(season.seasonNumber),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8C13A),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Voir les épisodes'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _loadEpisodes(int seasonNumber) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            backgroundColor: Color(0xFF1D2F3E),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF8C13A)),
                ),
                SizedBox(height: 16),
                Text(
                  'Chargement des épisodes...',
                  style: TextStyle(color: Color(0xFFF4F6F8)),
                ),
              ],
            ),
          );
        },
      );

      final seasonDetails = await _tmdbService.getSeasonDetails(
        widget.serieId,
        seasonNumber,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final episodes = seasonDetails['episodes'] as List<dynamic>;
            return AlertDialog(
              backgroundColor: const Color(0xFF1D2F3E),
              title: Text(
                'Saison $seasonNumber',
                style: const TextStyle(
                  color: Color(0xFFF8C13A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: episodes.length,
                  itemBuilder: (context, index) {
                    final episode = episodes[index] as Map<String, dynamic>;
                    final episodeNumber = episode['episode_number'] as int;
                    final episodeName = episode['name'] as String;
                    final airDate = episode['air_date'] as String? ?? '';
                    final formattedDate =
                        airDate.isNotEmpty
                            ? _formatDate(airDate)
                            : 'Date inconnue';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      title: Text(
                        'E$episodeNumber. $episodeName',
                        style: const TextStyle(
                          color: Color(0xFFF4F6F8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFF8C13A),
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();

                        context.go(
                          '/series/detail/${widget.serieId}/season/$seasonNumber/episode/$episodeNumber',
                          extra: _tvShowDetails!.name,
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(color: Color(0xFFF8C13A)),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      // Ajout des boutons flottants pour watchlist et favoris
      floatingActionButton:
          _tvShowDetails == null
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
                    // Bouton pour marquer comme favoris
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
                      onPressed: _loadTvShowDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8C13A),
                        foregroundColor: const Color(0xFF16232E),
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : _tvShowDetails == null
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
                          _tvShowDetails!.backdropPath.isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl:
                                    'https://image.tmdb.org/t/p/w1280${_tvShowDetails!.backdropPath}',
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
                        _tvShowDetails!.name,
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
                      // Bouton À voir
                      IconButton(
                        icon:
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
                                  _isInWatchlist
                                      ? Icons.visibility
                                      : Icons.visibility_outlined,
                                  color:
                                      _isInWatchlist
                                          ? const Color(0xFFF8C13A)
                                          : Colors.white,
                                ),
                        onPressed: _toggleWatchlist,
                        tooltip:
                            _isInWatchlist
                                ? 'Marquer comme non vu'
                                : 'Marquer comme vu',
                      ),
                    ],
                    iconTheme: const IconThemeData(color: Color(0xFFF4F6F8)),
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
                              if (_tvShowDetails!.posterPath.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        'https://image.tmdb.org/t/p/w500${_tvShowDetails!.posterPath}',
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
                                      _tvShowDetails!.name,
                                      style: const TextStyle(
                                        color: Color(0xFFF4F6F8),
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    if (_tvShowDetails!
                                        .firstAirDate
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '(${_tvShowDetails!.firstAirDate.substring(0, 4)})',
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
                                              _tvShowDetails!.voteAverage / 2,
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
                                          '${_tvShowDetails!.voteAverage.toStringAsFixed(1)}/10',
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
                                          _tvShowDetails!.genres.map((genre) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1D2F3E),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFF8C13A,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                genre.name,
                                                style: const TextStyle(
                                                  color: Color(0xFFF4F6F8),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          }).toList(),
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
                            _tvShowDetails!.overview.isNotEmpty
                                ? _tvShowDetails!.overview
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
                            'Première diffusion',
                            _formatDate(_tvShowDetails!.firstAirDate),
                          ),
                          _buildInfoRow(
                            'Dernière diffusion',
                            _formatDate(_tvShowDetails!.lastAirDate),
                          ),
                          _buildInfoRow(
                            'Nombre de saisons',
                            '${_tvShowDetails!.numberOfSeasons}',
                          ),
                          _buildInfoRow(
                            'Nombre d\'épisodes',
                            '${_tvShowDetails!.numberOfEpisodes}',
                          ),
                          _buildInfoRow('Statut', _tvShowDetails!.status),

                          const SizedBox(height: 24),

                          if (_tvShowDetails!.creators.isNotEmpty) ...[
                            const Text(
                              'Créateurs',
                              style: TextStyle(
                                color: Color(0xFFF8C13A),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _tvShowDetails!.creators.length,
                                itemBuilder: (context, index) {
                                  final creator =
                                      _tvShowDetails!.creators[index];
                                  return _buildPersonCard(
                                    name: creator.name,
                                    role: 'Créateur',
                                    profilePath: creator.profilePath,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          if (_tvShowDetails!.cast.isNotEmpty) ...[
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
                                itemCount: _tvShowDetails!.cast.length,
                                itemBuilder: (context, index) {
                                  final actor = _tvShowDetails!.cast[index];
                                  return _buildPersonCard(
                                    name: actor.name,
                                    role: actor.character,
                                    profilePath: actor.profilePath,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          _buildSeasons(),

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
