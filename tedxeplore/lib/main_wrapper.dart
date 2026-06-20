import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/favorites.dart';
import 'screens/settings.dart'; // Importiamo la nuova pagina impostazioni
import 'models/profile_model.dart';
import 'models/video_model.dart';
import 'services/aws_service.dart';

class MainWrapper extends StatefulWidget {
  final UserProfileData userProfile;

  const MainWrapper({super.key, required this.userProfile});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  final List<String> _favoriteIds = [];
  final AwsService _awsService = AwsService();
  List<TedVideo> _allLoadedVideos = [];

  @override
  void initState() {
    super.initState();
    _catturaTuttiIVideoCatalogo();
  }

  Future<void> _catturaTuttiIVideoCatalogo() async {
    try {
      final latest = await _awsService.fetchLatestVideos();
      final primaChiaveGenere = widget.userProfile.percentualiGeneri.keys.first;
      final consigliati = await _awsService.fetchRecommendedVideos([primaChiaveGenere.toLowerCase()]);
      
      setState(() {
        final Map<String, TedVideo> rimozioneDuplicati = {};
        for (var v in [...latest, ...consigliati]) {
          rimozioneDuplicati[v.id] = v;
        }
        _allLoadedVideos = rimozioneDuplicati.values.toList();
      });
    } catch (_) {}
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        userProfile: widget.userProfile,
      ),
      FavoritesScreen(
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        allVideos: _allLoadedVideos,
      ),
      SettingsScreen(userProfile: widget.userProfile), // Terzo tab: Impostazioni
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          
          // BARRA INFERIORE GALLEGGIANTE (STILE APPLE BOOKS)
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
                            _buildNavItem(2, CupertinoIcons.gear, CupertinoIcons.gear_solid), // Ingranaggio Impostazioni
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