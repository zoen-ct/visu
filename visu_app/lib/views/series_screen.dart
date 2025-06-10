import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '/visu.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  final SerieService _serieService = SerieService();
  final SupabaseHistoryService _historyService = SupabaseHistoryService();
  final TMDbService _tmdbService = TMDbService();

  List<SerieWithFirstEpisode>?
  _watchlistSeries; // Séries non commencées avec infos du premier épisode
  List<SerieWithProgress>? _inProgressSeries; // Séries en cours
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Récupérer toutes les séries dans la watchlist
      final allWatchlistSeries = await _serieService.getWatchlist();

      // Récupérer l'historique des épisodes vus
      final watchHistory = await _historyService.getHistoryByType(MediaType.tv);

      // Debug: Afficher l'historique pour vérifier s'il contient des données
      debugPrint(
        'Nombre d\'entrées dans l\'historique: ${watchHistory.length}',
      );
      for (var item in watchHistory) {
        debugPrint(
          'Historique: série ${item['item_id']}, saison ${item['season_number']}, épisode ${item['episode_number']}',
        );
      }

      final List<SerieWithProgress> inProgressSeries = [];
      final List<SerieWithFirstEpisode> notStartedSeries = [];
      final Map<int, List<Map<String, dynamic>>> watchedEpisodesBySerieId = {};

      // Organiser les épisodes vus par série
      for (final item in watchHistory) {
        if (item['item_id'] != null &&
            item['season_number'] != null &&
            item['episode_number'] != null) {
          final serieId = item['item_id'] as int;
          if (!watchedEpisodesBySerieId.containsKey(serieId)) {
            watchedEpisodesBySerieId[serieId] = [];
          }
          watchedEpisodesBySerieId[serieId]!.add(item);
        }
      }

      // Debug: Afficher les séries qui ont des épisodes vus
      for (var serieId in watchedEpisodesBySerieId.keys) {
        debugPrint(
          'Série $serieId a ${watchedEpisodesBySerieId[serieId]!.length} épisodes vus',
        );
      }

      // Trier les séries entre "en cours" et "non commencées"
      for (final serie in allWatchlistSeries) {
        debugPrint('Traitement de la série ${serie.id} (${serie.title})');
        // Vérifier si cette série est dans l'historique (au moins un épisode vu)
        final serieHistory = watchedEpisodesBySerieId[serie.id] ?? [];

        debugPrint(
          'Série ${serie.id} a ${serieHistory.length} épisodes dans l\'historique',
        );

        if (serieHistory.isNotEmpty) {
          debugPrint('Série ${serie.id} est EN COURS');
          // Trouver le dernier épisode vu (le plus récent)
          serieHistory.sort((a, b) {
            final aSeasonNum = a['season_number'] as int;
            final bSeasonNum = b['season_number'] as int;
            if (aSeasonNum != bSeasonNum) return bSeasonNum - aSeasonNum;

            final aEpisodeNum = a['episode_number'] as int;
            final bEpisodeNum = b['episode_number'] as int;
            return bEpisodeNum - aEpisodeNum;
          });

          final lastWatched = serieHistory.first;
          final lastSeasonNumber = lastWatched['season_number'] as int;
          final lastEpisodeNumber = lastWatched['episode_number'] as int;

          // Récupérer les détails de la saison pour connaître le prochain épisode
          try {
            final seasonDetails = await _tmdbService.getSeasonDetails(
              serie.id,
              lastSeasonNumber,
            );

            final episodes = seasonDetails['episodes'] as List<dynamic>;
            int nextEpisodeNumber = lastEpisodeNumber + 1;

            // Calculer la progression totale
            int totalWatchedEpisodes = serieHistory.length;
            int totalEpisodesInSeason = episodes.length;

            // Vérifier si le prochain épisode existe dans cette saison
            if (nextEpisodeNumber <= episodes.length) {
              // Récupérer les infos du prochain épisode
              final nextEpisode = episodes.firstWhere(
                (e) => e['episode_number'] == nextEpisodeNumber,
                orElse: () => null,
              );

              if (nextEpisode != null) {
                inProgressSeries.add(
                  SerieWithProgress(
                    serie: serie,
                    currentSeason: lastSeasonNumber,
                    nextEpisode: nextEpisodeNumber,
                    totalEpisodes: totalEpisodesInSeason,
                    watchedEpisodes: totalWatchedEpisodes,
                    nextEpisodeDetails: nextEpisode,
                  ),
                );
                continue; // Passer à la série suivante
              }
            }

            // Si on arrive ici, il faut vérifier la saison suivante
            try {
              final nextSeasonNumber = lastSeasonNumber + 1;
              final nextSeasonDetails = await _tmdbService.getSeasonDetails(
                serie.id,
                nextSeasonNumber,
              );

              final nextSeasonEpisodes =
                  nextSeasonDetails['episodes'] as List<dynamic>;
              if (nextSeasonEpisodes.isNotEmpty) {
                final nextEpisode = nextSeasonEpisodes.first;
                inProgressSeries.add(
                  SerieWithProgress(
                    serie: serie,
                    currentSeason: nextSeasonNumber,
                    nextEpisode: 1,
                    totalEpisodes: nextSeasonEpisodes.length,
                    watchedEpisodes: totalWatchedEpisodes,
                    nextEpisodeDetails: nextEpisode,
                  ),
                );
                continue; // Passer à la série suivante
              }
            } catch (e) {
              // Pas de saison suivante, on considère la série comme terminée
              inProgressSeries.add(
                SerieWithProgress(
                  serie: serie,
                  currentSeason: lastSeasonNumber,
                  nextEpisode: lastEpisodeNumber,
                  totalEpisodes: totalEpisodesInSeason,
                  watchedEpisodes: totalWatchedEpisodes,
                  nextEpisodeDetails: episodes.last,
                  isCompleted: true,
                ),
              );
              continue;
            }
          } catch (e) {
            // Erreur lors de la récupération des détails de la saison
            debugPrint('Erreur pour la série ${serie.id}: $e');
          }
        } else {
          // Aucun épisode vu, série non commencée
          try {
            // Récupérer les détails du premier épisode
            final seasonDetails = await _tmdbService.getSeasonDetails(
              serie.id,
              1, // Première saison
            );

            final episodes = seasonDetails['episodes'] as List<dynamic>;
            if (episodes.isNotEmpty) {
              final firstEpisode = episodes.first;
              notStartedSeries.add(
                SerieWithFirstEpisode(
                  serie: serie,
                  firstEpisodeDetails: firstEpisode,
                ),
              );
            } else {
              // Si pas d'épisodes disponibles, on ajoute quand même la série
              // avec des informations minimales
              notStartedSeries.add(
                SerieWithFirstEpisode(
                  serie: serie,
                  firstEpisodeDetails: {
                    'name': 'Premier épisode',
                    'overview': 'Aucune description disponible',
                    'still_path': '',
                  },
                ),
              );
            }
          } catch (e) {
            debugPrint(
              'Erreur lors de la récupération du premier épisode pour ${serie.id}: $e',
            );
            // En cas d'erreur, on ajoute quand même la série avec des informations minimales
            notStartedSeries.add(
              SerieWithFirstEpisode(
                serie: serie,
                firstEpisodeDetails: {
                  'name': 'Premier épisode',
                  'overview': 'Aucune description disponible',
                  'still_path': '',
                },
              ),
            );
          }
        }
      }

      if (mounted) {
        setState(() {
          _inProgressSeries = inProgressSeries;
          _watchlistSeries = notStartedSeries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des séries: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToSerieDetail(BuildContext context, Serie serie) {
    context.push('/series/detail/${serie.id}');
  }

  void _navigateToEpisodeDetail(
    BuildContext context,
    SerieWithProgress serieProgress,
  ) {
    context.go(
      '/series/detail/${serieProgress.serie.id}/season/${serieProgress.currentSeason}/episode/${serieProgress.nextEpisode}',
      extra: serieProgress.serie.title,
    );
  }

  void _navigateToFirstEpisodeDetail(
    BuildContext context,
    SerieWithFirstEpisode serieWithEpisode,
  ) {
    context.go(
      '/series/detail/${serieWithEpisode.serie.id}/season/1/episode/1',
      extra: serieWithEpisode.serie.title,
    );
  }

  Future<void> _markEpisodeAsWatched(SerieWithProgress serieProgress) async {
    try {
      final success = await _historyService.markAsWatched(
        itemId: serieProgress.serie.id,
        mediaType: MediaType.tv,
        title: serieProgress.serie.title,
        posterPath: serieProgress.serie.imageUrl.replaceAll(
          'https://image.tmdb.org/t/p/w500',
          '',
        ),
        seasonNumber: serieProgress.currentSeason,
        episodeNumber: serieProgress.nextEpisode,
        watched: true,
      );

      if (success) {
        // Recharger les données pour mettre à jour l'UI
        _loadSeries();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Épisode marqué comme vu'),
              backgroundColor: Color(0xFF16232E),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _markFirstEpisodeAsWatched(
    SerieWithFirstEpisode serieWithEpisode,
  ) async {
    try {
      final success = await _historyService.markAsWatched(
        itemId: serieWithEpisode.serie.id,
        mediaType: MediaType.tv,
        title: serieWithEpisode.serie.title,
        posterPath: serieWithEpisode.serie.imageUrl.replaceAll(
          'https://image.tmdb.org/t/p/w500',
          '',
        ),
        seasonNumber: 1, // Premier épisode = saison 1
        episodeNumber: 1, // Premier épisode = épisode 1
        watched: true,
      );

      if (success) {
        // Recharger les données pour mettre à jour l'UI
        _loadSeries();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Premier épisode marqué comme vu'),
              backgroundColor: Color(0xFF16232E),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF8C13A)),
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
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSeries,
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

    final bool hasInProgressSeries =
        _inProgressSeries != null && _inProgressSeries!.isNotEmpty;
    final bool hasWatchlistSeries =
        _watchlistSeries != null && _watchlistSeries!.isNotEmpty;

    if (!hasInProgressSeries && !hasWatchlistSeries) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Aucune série dans votre liste',
              style: TextStyle(color: Color(0xFFF4F6F8), fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/search'),
              icon: const Icon(Icons.search),
              label: const Text('Chercher des séries'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8C13A),
                foregroundColor: const Color(0xFF16232E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSeries,
      color: const Color(0xFFF8C13A),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        children: [
          // Section séries en cours
          if (hasInProgressSeries) ...[
            const Text(
              'Séries en cours',
              style: TextStyle(
                color: Color(0xFFF8C13A),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(_inProgressSeries!.length, (index) {
              final serieProgress = _inProgressSeries![index];
              return SerieProgressCard(
                serieProgress: serieProgress,
                onTapSerie:
                    () => _navigateToSerieDetail(context, serieProgress.serie),
                onTapEpisode:
                    () => _navigateToEpisodeDetail(context, serieProgress),
                onMarkWatched: () => _markEpisodeAsWatched(serieProgress),
              );
            }),
            const SizedBox(height: 24),
          ],

          // Section séries à commencer
          if (hasWatchlistSeries) ...[
            const Text(
              'Séries à commencer',
              style: TextStyle(
                color: Color(0xFFF8C13A),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(_watchlistSeries!.length, (index) {
              final serieWithEpisode = _watchlistSeries![index];
              return SerieWithFirstEpisodeCard(
                serieWithEpisode: serieWithEpisode,
                onTapSerie:
                    () =>
                        _navigateToSerieDetail(context, serieWithEpisode.serie),
                onMarkWatched:
                    () => _markFirstEpisodeAsWatched(serieWithEpisode),
                onTapEpisode:
                    () => _navigateToFirstEpisodeDetail(
                      context,
                      serieWithEpisode,
                    ),
              );
            }),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16232E),
        title: const Text(
          'Mes séries',
          style: TextStyle(
            color: Color(0xFFF8C13A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildContent(),
    );
  }
}

// Classe pour stocker les informations sur la progression d'une série
class SerieWithProgress {
  final Serie serie;
  final int currentSeason;
  final int nextEpisode;
  final int totalEpisodes;
  final int watchedEpisodes;
  final Map<String, dynamic> nextEpisodeDetails;
  final bool isCompleted;

  SerieWithProgress({
    required this.serie,
    required this.currentSeason,
    required this.nextEpisode,
    required this.totalEpisodes,
    required this.watchedEpisodes,
    required this.nextEpisodeDetails,
    this.isCompleted = false,
  });
}

// Classe étendue pour stocker les informations sur une série non commencée avec les détails du premier épisode
class SerieWithFirstEpisode {
  final Serie serie;
  final Map<String, dynamic> firstEpisodeDetails;

  SerieWithFirstEpisode({
    required this.serie,
    required this.firstEpisodeDetails,
  });
}

// Widget pour afficher une série en cours avec les détails du prochain épisode
class SerieProgressCard extends StatelessWidget {
  final SerieWithProgress serieProgress;
  final VoidCallback onTapSerie;
  final VoidCallback onTapEpisode;
  final VoidCallback onMarkWatched;

  const SerieProgressCard({
    Key? key,
    required this.serieProgress,
    required this.onTapSerie,
    required this.onTapEpisode,
    required this.onMarkWatched,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final episode = serieProgress.nextEpisodeDetails;
    final String episodeTitle =
        episode['name'] ?? 'Épisode ${serieProgress.nextEpisode}';
    final String imageUrl = serieProgress.serie.imageUrl;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1D2F3E),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTapEpisode,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image de la série
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
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
                        color: Colors.grey[800],
                        width: 60,
                        height: 90,
                        child: const Icon(Icons.error, color: Colors.white),
                      ),
                ),
              ),

              const SizedBox(width: 12),

              // Informations sur la série et l'épisode
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre de la série
                    Text(
                      serieProgress.serie.title,
                      style: const TextStyle(
                        color: Color(0xFFF8C13A),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Indicateur de série terminée ou numéro de saison et épisode
                    serieProgress.isCompleted
                        ? const Text(
                          "Série terminée",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : Text(
                          'S${serieProgress.currentSeason} | E${serieProgress.nextEpisode}',
                          style: const TextStyle(
                            color: Color(0xFFF4F6F8),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                    if (!serieProgress.isCompleted) ...[
                      const SizedBox(height: 4),

                      // Titre de l'épisode
                      Text(
                        episodeTitle,
                        style: const TextStyle(
                          color: Color(0xFFF4F6F8),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Barre de progression avec texte
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value:
                                    serieProgress.watchedEpisodes /
                                    (serieProgress.watchedEpisodes +
                                        serieProgress.totalEpisodes -
                                        serieProgress.nextEpisode +
                                        1),
                                backgroundColor: const Color(0xFF16232E),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFF8C13A),
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${serieProgress.watchedEpisodes}/${serieProgress.watchedEpisodes + serieProgress.totalEpisodes - serieProgress.nextEpisode + 1}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Bouton pour marquer comme vu ou icône de succès pour les séries terminées
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      serieProgress.isCompleted
                          ? Colors.green
                          : const Color(0xFF3A4654),
                  shape: BoxShape.circle,
                ),
                child:
                    serieProgress.isCompleted
                        ? const Icon(
                          Icons.done_all,
                          color: Colors.white,
                          size: 20,
                        )
                        : IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: onMarkWatched,
                          icon: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: 'Marquer comme vu',
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget pour afficher une série non commencée avec les détails du premier épisode
class SerieWithFirstEpisodeCard extends StatelessWidget {
  final SerieWithFirstEpisode serieWithEpisode;
  final VoidCallback onTapSerie;
  final VoidCallback onMarkWatched;
  final VoidCallback? onTapEpisode;

  const SerieWithFirstEpisodeCard({
    Key? key,
    required this.serieWithEpisode,
    required this.onTapSerie,
    required this.onMarkWatched,
    this.onTapEpisode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final episode = serieWithEpisode.firstEpisodeDetails;
    final String episodeTitle = episode['name'] ?? 'Épisode 1';

    // Utiliser l'image de la série pour l'affichage
    final String imageUrl = serieWithEpisode.serie.imageUrl;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1D2F3E),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTapEpisode ?? onTapSerie,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image de la série
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
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
                        color: Colors.grey[800],
                        width: 60,
                        height: 90,
                        child: const Icon(Icons.error, color: Colors.white),
                      ),
                ),
              ),

              const SizedBox(width: 12),

              // Informations sur la série et l'épisode
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre de la série
                    Text(
                      serieWithEpisode.serie.title,
                      style: const TextStyle(
                        color: Color(0xFFF8C13A),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Premier épisode
                    Text(
                      'S1 | E1',
                      style: const TextStyle(
                        color: Color(0xFFF4F6F8),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Titre du premier épisode
                    Text(
                      episodeTitle,
                      style: const TextStyle(
                        color: Color(0xFFF4F6F8),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Bouton pour marquer comme vu
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4654),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onMarkWatched,
                  icon: const Icon(Icons.check, color: Colors.white, size: 20),
                  tooltip: 'Marquer comme vu',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
