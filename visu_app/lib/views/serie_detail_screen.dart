import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '/visu.dart';

class SerieDetailScreen extends StatefulWidget {

  const SerieDetailScreen({super.key, required this.serieId});
  final int serieId;

  @override
  State<SerieDetailScreen> createState() => _SerieDetailScreenState();
}

class _SerieDetailScreenState extends State<SerieDetailScreen>
    with SingleTickerProviderStateMixin {
  late TMDbService _tmdbService;
  TvShowDetails? _tvShowDetails;
  bool _isLoading = true;
  String? _errorMessage;

  bool _isFavorite = false;
  bool _isInWatchlist = false;
  bool _isFavoriteLoading = false;
  bool _isWatchlistLoading = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tmdbService = TMDbService();
    _tabController = TabController(length: 2, vsync: this);
    _loadTvShowDetails();
    _checkFavoriteStatus();
    _checkWatchlistStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTvShowDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final detailsJson = await _tmdbService.getTvShowDetails(widget.serieId);
      final details = TvShowDetails.fromJson(detailsJson as Map<String, dynamic>);

      if (mounted) {
        setState(() {
          _tvShowDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des détails de la série';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await _tmdbService.isFavorite(widget.serieId);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Future<void> _checkWatchlistStatus() async {
    final isInWatchlist = await _tmdbService.isInWatchlist(widget.serieId);
    if (mounted) {
      setState(() {
        _isInWatchlist = isInWatchlist;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriteLoading) return;

    setState(() {
      _isFavoriteLoading = true;
    });

    bool success;
    if (_isFavorite) {
      success = await _tmdbService.removeFromFavorites(widget.serieId);
    } else {
      success = await _tmdbService.addToFavorites(widget.serieId);
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
  }

  Future<void> _toggleWatchlist() async {
    if (_isWatchlistLoading) return;

    setState(() {
      _isWatchlistLoading = true;
    });

    bool success;
    if (_isInWatchlist) {
      success = await _tmdbService.removeFromWatchlist(widget.serieId);
    } else {
      success = await _tmdbService.addToWatchlist(widget.serieId);
    }

    if (mounted && success) {
      setState(() {
        _isInWatchlist = !_isInWatchlist;
        _isWatchlistLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isInWatchlist
                ? 'Ajouté à la liste "À voir"'
                : 'Retiré de la liste "À voir"',
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

  Widget _buildOverviewTab() {
    if (_tvShowDetails == null) {
      return const Center(
        child: Text(
          'Aucune information disponible',
          style: TextStyle(color: Color(0xFFF4F6F8)),
        ),
      );
    }

    final details = _tvShowDetails!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Synopsis
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
            details.overview.isNotEmpty
                ? details.overview
                : 'Aucun synopsis disponible',
            style: const TextStyle(
              color: Color(0xFFF4F6F8),
              fontSize: 16,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Informations
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
            _formatDate(details.firstAirDate),
          ),
          _buildInfoRow('Dernière diffusion', _formatDate(details.lastAirDate)),
          _buildInfoRow('Nombre de saisons', '${details.numberOfSeasons}'),
          _buildInfoRow('Nombre d\'épisodes', '${details.numberOfEpisodes}'),
          _buildInfoRow('Statut', details.status),

          const SizedBox(height: 24),

          // Créateurs
          if (details.creators.isNotEmpty) ...[
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
                itemCount: details.creators.length,
                itemBuilder: (context, index) {
                  final creator = details.creators[index];
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

          // Casting
          if (details.cast.isNotEmpty) ...[
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
                itemCount: details.cast.length,
                itemBuilder: (context, index) {
                  final actor = details.cast[index];
                  return _buildPersonCard(
                    name: actor.name,
                    role: actor.character,
                    profilePath: actor.profilePath,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeasonsTab() {
    if (_tvShowDetails == null || _tvShowDetails!.seasons.isEmpty) {
      return const Center(
        child: Text(
          'Aucune saison disponible',
          style: TextStyle(color: Color(0xFFF4F6F8)),
        ),
      );
    }

    final seasons =
        _tvShowDetails!.seasons
            .where(
              (s) => s.seasonNumber > 0,
            ) // Exclure la saison 0 (souvent les spéciaux)
            .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
                      imageUrl: _tmdbService.getImageUrl(
                        season.posterPath,
                        size: TMDbConfig.profileSize,
                      ),
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
                            child: const Icon(Icons.error, color: Colors.red),
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
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
              // Ici, nous pourrions charger la liste des épisodes pour chaque saison
              // Mais pour éviter de surcharger l'API, nous affichons juste un message
              const Text(
                'Appuyez pour voir les épisodes',
                style: TextStyle(
                  color: Color(0xFFF8C13A),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
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
                      imageUrl: _tmdbService.getImageUrl(
                        profilePath,
                        size: TMDbConfig.profileSize,
                      ),
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
                  // AppBar avec l'image de fond
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    backgroundColor: const Color(0xFF16232E),
                    flexibleSpace: FlexibleSpaceBar(
                      background:
                          _tvShowDetails!.backdropPath.isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl: _tmdbService.getImageUrl(
                                  _tvShowDetails!.backdropPath,
                                  size: TMDbConfig.backdropSize,
                                ),
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
                      // Bouton Favoris
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
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color:
                                      _isInWatchlist
                                          ? const Color(0xFFF8C13A)
                                          : Colors.white,
                                ),
                        onPressed: _toggleWatchlist,
                        tooltip:
                            _isInWatchlist
                                ? 'Retirer de la liste "À voir"'
                                : 'Ajouter à la liste "À voir"',
                      ),
                    ],
                  ),

                  // Contenu principal
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // En-tête avec l'affiche et les informations
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Affiche
                              if (_tvShowDetails!.posterPath.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: _tmdbService.getImageUrl(
                                      _tvShowDetails!.posterPath,
                                    ),
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

                              // Informations
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

                                    const SizedBox(height: 8),

                                    // Note
                                    Row(
                                      children: [
                                        RatingBar.builder(
                                          initialRating:
                                              _tvShowDetails!.voteAverage /
                                              2, // TMDb utilise une échelle de 10
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

                                    // Genres
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

                          // Onglets
                          TabBar(
                            controller: _tabController,
                            indicatorColor: const Color(0xFFF8C13A),
                            labelColor: const Color(0xFFF8C13A),
                            unselectedLabelColor: Colors.grey,
                            tabs: const [
                              Tab(text: 'À propos'),
                              Tab(text: 'Saisons'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Contenu des onglets
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [_buildOverviewTab(), _buildSeasonsTab()],
                    ),
                  ),
                ],
              ),
    );
  }
}
