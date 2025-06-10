import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '/visu.dart';

class EpisodeDetailScreen extends StatefulWidget {
  const EpisodeDetailScreen({
    super.key,
    required this.serieId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.serieName,
  });

  final int serieId;
  final int seasonNumber;
  final int episodeNumber;
  final String serieName;

  @override
  State<EpisodeDetailScreen> createState() => _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends State<EpisodeDetailScreen> {
  final TMDbService _tmdbService = TMDbService();
  final SupabaseHistoryService _historyService = SupabaseHistoryService();
  late Future<Episode> _episodeFuture;
  bool _isWatched = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEpisodeDetails();
  }

  void _loadEpisodeDetails() {
    _episodeFuture = _tmdbService.getEpisodeDetails(
      widget.serieId,
      widget.seasonNumber,
      widget.episodeNumber,
    );
    _checkIfEpisodeIsWatched();
  }

  Future<void> _checkIfEpisodeIsWatched() async {
    try {
      final isWatched = await _historyService.isWatched(
        itemId: widget.serieId,
        mediaType: MediaType.tv,
        seasonNumber: widget.seasonNumber,
        episodeNumber: widget.episodeNumber,
      );

      if (mounted) {
        setState(() {
          _isWatched = isWatched;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification si l\'épisode est vu: $e');
    }
  }

  Future<void> _toggleWatchedStatus(Episode episode) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _historyService.markAsWatched(
        itemId: widget.serieId,
        mediaType: MediaType.tv,
        seasonNumber: widget.seasonNumber,
        episodeNumber: widget.episodeNumber,
        title:
            '${widget.serieName} - S${widget.seasonNumber}E${widget.episodeNumber} - ${episode.name}',
        posterPath: episode.stillPath,
        watched: !_isWatched,
      );

      if (success && mounted) {
        setState(() {
          _isWatched = !_isWatched;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isWatched
                  ? 'Épisode marqué comme vu'
                  : 'Épisode marqué comme non vu',
            ),
            backgroundColor: const Color(0xFF16232E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16232E),
        title: Text(
          widget.serieName,
          style: const TextStyle(color: Color(0xFFF8C13A)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFF4F6F8)),
      ),
      body: FutureBuilder<Episode>(
        future: _episodeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF8C13A)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Aucune donnée disponible',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final episode = snapshot.data!;
          return _buildEpisodeDetails(episode);
        },
      ),
    );
  }

  Widget _buildEpisodeDetails(Episode episode) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');
    final formattedDate = dateFormat.format(episode.airDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image de l'épisode
          if (episode.stillPath.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl:
                    'https://image.tmdb.org/t/p/w1280${episode.stillPath}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFF8C13A),
                          ),
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.white),
                      ),
                    ),
              ),
            ),
          const SizedBox(height: 16),

          // Numéro et titre de l'épisode
          Text(
            'S${widget.seasonNumber.toString().padLeft(2, '0')}E${episode.episodeNumber.toString().padLeft(2, '0')} - ${episode.name}',
            style: const TextStyle(
              color: Color(0xFFF8C13A),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Date de diffusion
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'Diffusé le $formattedDate',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),

          // Durée de l'épisode
          if (episode.runtime > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${episode.runtime} minutes',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],

          // Note
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFF8C13A), size: 16),
              const SizedBox(width: 8),
              Text(
                '${episode.voteAverage.toStringAsFixed(1)}/10',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bouton pour marquer comme vu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _toggleWatchedStatus(episode),
              icon: Icon(_isWatched ? Icons.visibility_off : Icons.visibility),
              label: Text(
                _isWatched ? 'Marquer comme non vu' : 'Marquer comme vu',
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    _isWatched
                        ? Colors.green.shade700
                        : const Color(0xFFF8C13A),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Synopsis
          const Text(
            'Synopsis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            episode.overview.isNotEmpty
                ? episode.overview
                : 'Aucun synopsis disponible pour cet épisode.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
