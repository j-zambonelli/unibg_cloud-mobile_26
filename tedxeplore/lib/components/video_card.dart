import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TedxVideoCard extends StatelessWidget {
  final String title;
  final String speaker;
  final String imageUrl;
  final String duration;
  final String views;
  final String year;
  final bool isFavorite;
  final bool isWatched; 
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const TedxVideoCard({
    super.key,
    required this.title,
    required this.speaker,
    required this.imageUrl,
    required this.duration,
    required this.views,
    required this.year,
    required this.isFavorite,
    this.isWatched = false,
    required this.onTap,
    required this.onToggleFavorite,
  });

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF1C1C1E), 
      child: const Center(
        child: Icon(
          CupertinoIcons.eye_slash, 
          color: Color(0xFF48484A),    
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 240, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12), 
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  // Barra di progresso in basso se il video è stato visto/iniziato
                  if (isWatched)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                        child: const LinearProgressIndicator(
                          value: 1.0,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF3B30)),
                          minHeight: 3,
                        ),
                      ),
                    ),
                  // Bottone Preferito iOS
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onToggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                          color: isFavorite ? const Color(0xFFFF3B30) : Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  // Badge Durata Video
                  Positioned(
                    bottom: isWatched ? 8 : 6, // Leggermente rialzato se c'è la barra
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.clock, color: Colors.white, size: 11),
                          const SizedBox(width: 3),
                          Text(
                            duration, 
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 14, 
                fontWeight: FontWeight.w600, 
                letterSpacing: -0.2, 
              ),
            ),
            const SizedBox(height: 2),
            Text(
              speaker, 
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 2),
            Text(
              '$views • $year', 
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}