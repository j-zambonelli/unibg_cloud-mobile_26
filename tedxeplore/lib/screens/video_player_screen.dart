import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video_model.dart';
import '../services/storage_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final TedVideo video;
  final bool isFavorite;
  final Function(String) onToggleFavorite;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _storageService.addWatchedVideo(widget.video.id);
  }

  Future<void> _openWebTalk() async {
    final Uri url = Uri.parse(widget.video.videoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    }
  }

  void _onClosePlayer() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8), // Sfondo trasparente che oscura la home sotto
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bottone di chiusura (X) in alto a destra dell'overlay
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _onClosePlayer,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2C2C2E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.xmark, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Box del Player in Overlay con miniatura e pulsante per aprire il browser
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: GestureDetector(
                        onTap: _openWebTalk,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            widget.video.thumbnail.isNotEmpty
                                ? Image.network(widget.video.thumbnail, width: double.infinity, fit: BoxFit.cover)
                                : Container(color: Colors.grey[900]),
                            
                            Container(
                              color: Colors.black.withOpacity(0.3),
                            ),

                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF3B30),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(CupertinoIcons.play_fill, color: Colors.white, size: 36),
                            ),
                            
                            Positioned(
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "▶ Guarda il Talk ufficiale nel browser",
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Titolo e Preferito
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.video.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          widget.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                          color: widget.isFavorite ? const Color(0xFFFF3B30) : Colors.white,
                          size: 28,
                        ),
                        onPressed: () => widget.onToggleFavorite(widget.video.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Speaker del Talk
                  Text(
                    widget.video.speakers,
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Informazioni sul Talk (Visualizzazioni e Anno)
                  Row(
                    children: [
                      const Icon(CupertinoIcons.eye, color: Color(0xFF8E8E93), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        widget.video.views,
                        style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                      ),
                      const Text("  •  ", style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
                      Text(
                        widget.video.publishedDate.toString(),
                        style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}