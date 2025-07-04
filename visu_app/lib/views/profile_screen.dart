import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '/visu.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseUserProfileService _userProfileService =
      SupabaseUserProfileService();
  final SupabaseFavoritesService _favoritesService = SupabaseFavoritesService();
  final SupabaseHistoryService _historyService = SupabaseHistoryService();
  final SupabaseAuthService _authService = SupabaseAuthService();

  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _userInfo;
  Map<String, dynamic> _userStats = {};
  List<SearchResult> _favorites = [];
  List<SearchResult> _watchHistory = [];
  List<Map<String, dynamic>> _historyRawData = [];
  String? _errorMessage;
  final Map<int, bool> _isRemovingFromHistory = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userProfile = await _userProfileService.getUserProfile();

      final favorites = await _favoritesService.getFavorites();

      final watchHistory = await _historyService.getHistory();

      _historyRawData = watchHistory;

      final Map<String, dynamic> userStats = {
        'totalWatchedMovies':
            watchHistory
                .where((item) => item['type'] == MediaType.movie.name)
                .length,
        'totalWatchedEpisodes':
            watchHistory
                .where((item) => item['type'] == MediaType.tv.name)
                .length,
        'totalFavorites': favorites.length,
        'totalWatchTimeHours':
            (watchHistory.length * 1.5).round(),
      };

      final List<SearchResult> favoriteResults =
          favorites.map((favorite) {
            return SearchResult(
              id: favorite['item_id'],
              mediaType:
                  favorite['type'] == 'movie' ? MediaType.movie : MediaType.tv,
              title: favorite['title'] ?? 'Sans titre',
              overview: '',
              posterPath: favorite['poster_path'],
              releaseDate: '',
              voteAverage: 0,
            );
          }).toList();

      final List<SearchResult> historyResults =
          watchHistory.map((item) {
            return SearchResult(
              id: item['item_id'],
              mediaType:
                  item['type'] == 'movie' ? MediaType.movie : MediaType.tv,
              title: item['title'] ?? 'Sans titre',
              overview: '',
              posterPath: item['poster_path'],
              releaseDate: '',
              voteAverage: 0,
              seasonNumber: item['season_number'],
              episodeNumber: item['episode_number'],
            );
          }).toList();

      if (mounted) {
        setState(() {
          _userInfo = userProfile;
          _userStats = userStats;
          _favorites = favoriteResults;
          _watchHistory = historyResults;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des données: $e';
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

  void _showEditProfileDialog() {
    final TextEditingController usernameController = TextEditingController(
      text:
          _userInfo != null && _userInfo!['username'] != null
              ? _userInfo!['username']
              : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D2F3E),
          title: const Text(
            'Modifier mon profil',
            style: TextStyle(color: Color(0xFFF8C13A)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFF8C13A),
                  backgroundImage:
                      _userInfo != null && _userInfo!['avatar_url'] != null
                          ? NetworkImage(_userInfo!['avatar_url'])
                          : null,
                  child:
                      _userInfo != null && _userInfo!['avatar_url'] != null
                          ? null
                          : const Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFF16232E),
                          ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "La fonctionnalité d'upload d'avatar sera disponible dans une version future",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: usernameController,
                  style: const TextStyle(color: Color(0xFFF4F6F8)),
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    labelStyle: TextStyle(color: Color(0xFFF8C13A)),
                    hintText: 'Entrez votre nom d\'utilisateur',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF8C13A)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFF8C13A),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Mise à jour du profil...',
                            style: TextStyle(color: Color(0xFFF4F6F8)),
                          ),
                        ],
                      ),
                    );
                  },
                );

                try {
                  final newUsername = usernameController.text.trim();
                  final success = await _userProfileService.updateUsername(
                    newUsername.isNotEmpty ? newUsername : 'Visueur',
                  );

                  if (success) {
                    await _loadUserData();
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil mis à jour avec succès'),
                        backgroundColor: Color(0xFF16232E),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pop();
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF8C13A),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeFromHistory(
    SearchResult media, {
    int? seasonNumber,
    int? episodeNumber,
  }) async {
    final mediaId = media.id;

    setState(() {
      _isRemovingFromHistory[mediaId] = true;
    });

    try {
      bool success;
      if (media.mediaType == MediaType.tv &&
          seasonNumber != null &&
          episodeNumber != null) {
        success = await _historyService.markAsWatched(
          itemId: mediaId,
          mediaType: MediaType.tv,
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
          watched: false,
        );
      } else {
        success = await _historyService.markAsWatched(
          itemId: mediaId,
          mediaType: media.mediaType,
          watched: false,
        );
      }

      if (success) {
        await _loadUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Retiré de l\'historique'),
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
    } finally {
      if (mounted) {
        setState(() {
          _isRemovingFromHistory[mediaId] = false;
        });
      }
    }
  }

  Widget _buildEpisodeCard(SearchResult media) {
    final seasonNumber = media.seasonNumber;
    final episodeNumber = media.episodeNumber;
    final episodeData = _historyRawData.firstWhere(
      (item) =>
          item['item_id'] == media.id &&
          item['season_number'] == seasonNumber &&
          item['episode_number'] == episodeNumber,
      orElse: () => {},
    );

    final isLoading = _isRemovingFromHistory[media.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1D2F3E),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetails(media),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: media.getFullPosterPath(),
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

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      media.title,
                      style: const TextStyle(
                        color: Color(0xFFF8C13A),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'S${seasonNumber?.toString().padLeft(2, '0') ?? '??'} | E${episodeNumber?.toString().padLeft(2, '0') ?? '??'}',
                      style: const TextStyle(
                        color: Color(0xFFF4F6F8),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      episodeData['overview'] ?? 'Épisode visionné',
                      style: const TextStyle(
                        color: Color(0xFFF4F6F8),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8C13A),
                  shape: BoxShape.circle,
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Color(0xFF16232E),
                            strokeWidth: 2,
                          ),
                        )
                        : IconButton(
                          padding: EdgeInsets.zero,
                          onPressed:
                              () => _removeFromHistory(
                                media,
                                seasonNumber: seasonNumber,
                                episodeNumber: episodeNumber,
                              ),
                          icon: const Icon(
                            Icons.visibility_off,
                            color: Color(0xFF16232E),
                            size: 20,
                          ),
                          tooltip: 'Retirer de l\'historique',
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16232E),
        title: const Text('Profil', style: TextStyle(color: Color(0xFFF8C13A))),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF8C13A)),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF8C13A),
          labelColor: const Color(0xFFF8C13A),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Profil'),
            Tab(text: 'Favoris'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF8C13A)),
                ),
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
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8C13A),
                        foregroundColor: const Color(0xFF16232E),
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildProfileTab(),
                  _buildFavoritesTab(),
                  _buildHistoryTab(),
                ],
              ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFF8C13A),
            backgroundImage:
                _userInfo != null && _userInfo!['avatar_url'] != null
                    ? NetworkImage(_userInfo!['avatar_url'])
                    : null,
            child:
                _userInfo != null && _userInfo!['avatar_url'] != null
                    ? null
                    : const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF16232E),
                    ),
          ),
          const SizedBox(height: 20),
          Text(
            _userInfo != null && _userInfo!['username'] != null
                ? _userInfo!['username']
                : 'Visueur',
            style: const TextStyle(
              color: Color(0xFFF4F6F8),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userInfo != null ? _userInfo!['email'] : 'utilisateur@vizu.com',
            style: const TextStyle(color: Color(0xFFF4F6F8), fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Modifier mon profil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D2F3E),
              foregroundColor: const Color(0xFFF8C13A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              _showEditProfileDialog();
            },
          ),

          const SizedBox(height: 32),

          const Text(
            'Statistiques de visionnage',
            style: TextStyle(
              color: Color(0xFFF8C13A),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: const Color(0xFF1D2F3E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStatRow(
                    Icons.movie,
                    'Films regardés',
                    _userStats['totalWatchedMovies']?.toString() ?? '0',
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    Icons.tv,
                    'Épisodes regardés',
                    _userStats['totalWatchedEpisodes']?.toString() ?? '0',
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    Icons.favorite,
                    'Favoris',
                    _userStats['totalFavorites']?.toString() ?? '0',
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    Icons.timer,
                    'Temps de visionnage',
                    '${_userStats['totalWatchTimeHours']?.toString() ?? '0'} heures',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Options',
            style: TextStyle(
              color: Color(0xFFF8C13A),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildProfileOption(Icons.settings, 'Paramètres'),
          _buildProfileOption(Icons.help_outline, 'Aide'),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    if (_favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, color: Color(0xFFF8C13A), size: 64),
            SizedBox(height: 16),
            Text(
              'Vous n\'avez pas encore de favoris',
              style: TextStyle(color: Color(0xFFF4F6F8), fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Ajoutez des films et séries à vos favoris\npour les retrouver ici',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final item = _favorites[index];
        return _buildMediaCard(item);
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_watchHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: Color(0xFFF8C13A), size: 64),
            SizedBox(height: 16),
            Text(
              'Votre historique est vide',
              style: TextStyle(color: Color(0xFFF4F6F8), fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Les films et épisodes que vous regardez\napparaîtront ici',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _watchHistory.length,
      itemBuilder: (context, index) {
        final item = _watchHistory[index];

        if (item.mediaType == MediaType.tv &&
            item.seasonNumber != null &&
            item.episodeNumber != null) {
          return _buildEpisodeCard(item);
        }

        return _buildMediaCard(item);
      },
    );
  }

  Widget _buildMediaCard(SearchResult media) {
    final isLoading = _isRemovingFromHistory[media.id] ?? false;
    final movieData = _historyRawData.firstWhere(
      (item) =>
          item['item_id'] == media.id && item['type'] == MediaType.movie.name,
      orElse: () => {},
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1D2F3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToDetails(media),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: media.getFullPosterPath(),
                width: 80,
                height: 120,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      width: 80,
                      height: 120,
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
                      width: 80,
                      height: 120,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                      ),
                    ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media.title,
                      style: const TextStyle(
                        color: Color(0xFFF8C13A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

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
                            media.getMediaTypeDisplay(),
                            style: const TextStyle(
                              color: Color(0xFF16232E),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (media.getYearFromReleaseDate().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            media.getYearFromReleaseDate(),
                            style: const TextStyle(
                              color: Color(0xFFF4F6F8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      movieData['overview'] ?? 'Film visionné',
                      style: const TextStyle(
                        color: Color(0xFFF4F6F8),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    if (media.voteAverage > 0) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFF8C13A),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            media.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFFF4F6F8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 8, top: 8),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8C13A),
                  shape: BoxShape.circle,
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Color(0xFF16232E),
                            strokeWidth: 2,
                          ),
                        )
                        : IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _removeFromHistory(media),
                          icon: const Icon(
                            Icons.visibility_off,
                            color: Color(0xFF16232E),
                            size: 20,
                          ),
                          tooltip: 'Retirer de l\'historique',
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFF8C13A), size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFFF4F6F8), fontSize: 16),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFF8C13A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1D2F3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFF8C13A)),
        title: Text(text, style: const TextStyle(color: Color(0xFFF4F6F8))),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFFF8C13A),
          size: 16,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigation vers $text à implémenter'),
              backgroundColor: const Color(0xFF16232E),
            ),
          );
        },
      ),
    );
  }
}
