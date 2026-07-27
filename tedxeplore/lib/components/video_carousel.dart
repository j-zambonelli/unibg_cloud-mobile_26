import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/video_model.dart';
import 'video_card.dart';

class VideoCarousel extends StatelessWidget {
  final String title;
  final List<TedVideo> videos;
  final bool showExpandButton;
  final List<String> favoriteIds;
  final List<String> watchedIds; 
  final Function(String) onToggleFavorite;
  final VoidCallback? onExpandPressed;
  final Function(TedVideo)? onVideoTap;

  const VideoCarousel({
    super.key,
    required this.title,
    required this.videos,
    this.showExpandButton = false,
    required this.favoriteIds,
    required this.watchedIds,
    required this.onToggleFavorite,
    this.onExpandPressed,
    this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              if (showExpandButton)
                GestureDetector(
                  onTap: onExpandPressed,
                  child: const Row(
                    children: [
                      Text(
                        "Vedi tutti",
                        style: TextStyle(color: Color(0xFFFF3B30), fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 4),
                      Icon(CupertinoIcons.chevron_forward, color: Color(0xFFFF3B30), size: 14),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: videos.isEmpty
              ? const Center(
                  child: Text("Nessun contenuto disponibile", style: TextStyle(color: Color(0xFF8E8E93))),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: videos.length,
                  padding: const EdgeInsets.only(left: 16.0),
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 14.0),
                      child: SizedBox(
                        width: 220,
                        child: TedxVideoCard(
                          title: video.title,
                          speaker: video.speakers,
                          imageUrl: video.thumbnail,
                          duration: video.duration,
                          views: video.views,
                          year: video.publishedDate.toString(),
                          isFavorite: favoriteIds.contains(video.id),
                          isWatched: watchedIds.contains(video.id),
                          onTap: () => onVideoTap?.call(video),
                          onToggleFavorite: () => onToggleFavorite(video.id),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}