import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/favorites.dart';
import 'screens/settings.dart'; 
import 'screens/video_player_screen.dart';
import 'models/profile_model.dart';
import 'models/video_model.dart';
import 'services/aws_service.dart';
import 'services/storage_service.dart';

class MainWrapper extends StatefulWidget {
  final UserProfileData userProfile;
  final String authToken;

  const MainWrapper({
    super.key, 
    required this.userProfile,
    required this.authToken,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  
  Set<String> _favoriteIds = {};
  Set<String> _watchedIds = {};
  Map<String, TedVideo> _cachedVideos = {};
  
  final AwsService _awsService = AwsService();
  final StorageService _storageService = StorageService();
  List<TedVideo> _allLoadedVideos = [];

  @override
  void initState() {
    super.initState();
    _inizializzaDati();
  }

  Future<void> _inizializzaDati() async {
    final watched = await _storageService.getWatchedIds();
    
    List<TedVideo> favoriteVideosList = [];
    try {
      favoriteVideosList = await _awsService.fetchFavoriteVideos(widget.authToken);
    } catch (e) {
      print("Errore caricamento preferiti: $e");
    }

    setState(() {
      _watchedIds = watched;
      for (var v in favoriteVideosList) {
        _cachedVideos[v.id] = v;
        _favoriteIds.add(v.id);
      }
      _allLoadedVideos = _cachedVideos.values.toList();
    });

    await _aggiornaCataloghiDaAws();
  }

  Future<void> _aggiornaCataloghiDaAws() async {
    try {
      final latest = await _awsService.fetchLatestVideos();
      final primaChiaveGenere = widget.userProfile.percentualiGeneri.keys.first;
      final consigliati = await _awsService.fetchRecommendedVideos([primaChiaveGenere.toLowerCase()]);
      
      registerVideos([...latest, ...consigliati]);
    } catch (_) {}
  }

  void registerVideos(List<TedVideo> newVideos) {
    bool updated = false;
    for (var v in newVideos) {
      if (!_cachedVideos.containsKey(v.id)) {
        _cachedVideos[v.id] = v;
        updated = true;
      }
    }
    if (updated) {
      setState(() {
        _allLoadedVideos = _cachedVideos.values.toList();
      });
    }
  }

  Future<void> _toggleFavorite(String id) async {
    final updatedFavorites = Set<String>.from(_favoriteIds);
    
    if (updatedFavorites.contains(id)) {
      updatedFavorites.remove(id);
    } else {
      updatedFavorites.add(id);
    }

    setState(() {
      _favoriteIds = updatedFavorites;
    });

    await _awsService.toggleFavoriteApi(widget.authToken, id);
  }

  void _openVideoPlayer(TedVideo video) async {
    // Apre il player in sovrapposizione trasparente (Overlay) sopra la schermata attuale
    await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false, 
        pageBuilder: (context, animation, secondaryAnimation) => VideoPlayerScreen(
          video: video,
          isFavorite: _favoriteIds.contains(video.id),
          onToggleFavorite: _toggleFavorite,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    
    // Aggiorna la lista dei video visti al ritorno dalla chiusura dell'overlay
    final watched = await _storageService.getWatchedIds();
    setState(() {
      _watchedIds = watched;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        favoriteIds: _favoriteIds.toList(),
        watchedIds: _watchedIds.toList(),
        onToggleFavorite: _toggleFavorite,
        onVideoTap: _openVideoPlayer,
        userProfile: widget.userProfile,
      ),
      FavoritesScreen(
        favoriteIds: _favoriteIds.toList(),
        watchedIds: _watchedIds.toList(),
        onToggleFavorite: _toggleFavorite,
        onVideoTap: _openVideoPlayer,
        allVideos: _allLoadedVideos,
      ),
      SettingsScreen(userProfile: widget.userProfile), 
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavItem(0, CupertinoIcons.house, CupertinoIcons.house_fill),
                            _buildNavItem(1, CupertinoIcons.heart, CupertinoIcons.heart_fill),
                            _buildNavItem(2, CupertinoIcons.gear, CupertinoIcons.gear_solid), 
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 0),
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E).withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                        ),
                        child: const Icon(CupertinoIcons.search, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 60,
        width: 60,
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? const Color(0xFFFF3B30) : const Color(0xFF8E8E93),
          size: 24,
        ),
      ),
    );
  }
}