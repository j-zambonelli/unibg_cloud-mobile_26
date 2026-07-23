import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../components/video_card.dart';
import '../models/video_model.dart';

class FavoritesScreen extends StatelessWidget {
  final List<String> favoriteIds;
  final List<String> watchedIds; 
  final Function(String) onToggleFavorite;
  final Function(TedVideo) onVideoTap;
  final List<TedVideo> allVideos; 

  const FavoritesScreen({
    super.key, 
    required this.favoriteIds, 
    required this.watchedIds,
    required this.onToggleFavorite,
    required this.onVideoTap,
    required this.allVideos,
  });

  @override
  Widget build(BuildContext context) {
    final List<TedVideo> realFavoriteVideos = allVideos
        .where((video) => favoriteIds.contains(video.id))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'Preferiti', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white, letterSpacing: -0.5),
        ),
      ),
      body: realFavoriteVideos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.heart, size: 64, color: Color(0xFF3A3A3C)),
                  const SizedBox(height: 16),
                  const Text(
                    'Nessun preferito', 
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'I video a cui metti like compariranno qui', 
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: realFavoriteVideos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 14, 
                mainAxisSpacing: 16, 
                childAspectRatio: 0.75, 
              ),
              itemBuilder: (context, index) {
                final video = realFavoriteVideos[index];
                return TedxVideoCard(
                  title: video.title,
                  speaker: video.speakers,
                  imageUrl: video.thumbnail,
                  duration: video.duration,
                  views: video.views,
                  year: video.publishedDate.toString(),
                  isFavorite: true, 
                  isWatched: watchedIds.contains(video.id), 
                  onTap: () => onVideoTap(video),            
                  onToggleFavorite: () => onToggleFavorite(video.id),
                );
              },
            ),
    );
  }
}