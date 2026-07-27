import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video_model.dart';
import '../services/storage_service.dart';
import '../services/aws_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final TedVideo video;
  final bool isFavorite;
  final Function(String) onToggleFavorite;
  
  final List<String> favoriteIds;
  final List<String> watchedIds;
  final Function(TedVideo) onVideoTap;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.favoriteIds,
    required this.watchedIds,
    required this.onVideoTap,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final StorageService _storageService = StorageService();
  final AwsService _awsService = AwsService(); 
  
  late YoutubePlayerController _ytController; 
  String? _youtubeId; 
  
  List<TedVideo> _relatedVideos = []; 
  bool _isLoadingRelated = true; 

  @override
  void initState() {
    super.initState();
    _storageService.addWatchedVideo(widget.video.id);

    _youtubeId = YoutubePlayerController.convertUrlToId(widget.video.videoUrl);

    if (_youtubeId != null && _youtubeId!.isNotEmpty) {
      _ytController = YoutubePlayerController.fromVideoId(
        videoId: _youtubeId!, 
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
        ),
      );
    }

    _loadRelatedVideos();
  }

  Future<void> _loadRelatedVideos() async {
    setState(() => _isLoadingRelated = true);
    try {
      final videos = await _awsService.fetchWatchNextVideos(widget.video.id);
      
      if (context.mounted) {
        setState(() {
          if (videos.isEmpty) {
            // Mock se il DB non ha correlati per questo video
            _relatedVideos = [
              TedVideo(
                id: "mock_1",
                title: "Il futuro dell'intelligenza artificiale e la sicurezza spaziale",
                speakers: "Jane Doe",
                thumbnail: "https://pi.tedcdn.com/r/talkstar-photos.s3.amazonaws.com/uploads/72bda89f-8bbf-4685-910a-2f151c4f0762/BillGates_2015-embed.jpg",
                duration: "14:20",
                views: "1.2M",
                publishedDate: "2025-10-12",
                videoUrl: "https://www.youtube.com/watch?v=8nt3edWLgIg",
              )
            ];
          } else {
            _relatedVideos = videos;
          }
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      print("Errore API Watch Next: $e"); 
      
      if (context.mounted) {
        setState(() {
          // Mock in caso di errore di rete / CORS
          _relatedVideos = [
            TedVideo(
              id: "mock_error",
              title: "Come costruire un orologio digitale custom",
              speakers: "Maker Team",
              thumbnail: "https://pi.tedcdn.com/r/talkstar-photos.s3.amazonaws.com/uploads/72bda89f-8bbf-4685-910a-2f151c4f0762/BillGates_2015-embed.jpg",
              duration: "08:45",
              views: "350K",
              publishedDate: "2026-07-20",
              videoUrl: "https://www.youtube.com/watch?v=8nt3edWLgIg",
            )
          ];
          _isLoadingRelated = false;
        });
      }
    }
  }

  void _onClosePlayer() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    if (_youtubeId != null && _youtubeId!.isNotEmpty) {
      _ytController.close();
    }
    super.dispose();
  }

  Widget _buildWatchNextChip(TedVideo nextVideo, bool isYouTubeVideo) {
    return GestureDetector(
      onTap: () {
        if (isYouTubeVideo) {
          _ytController.pauseVideo();
        }
        widget.onVideoTap(nextVideo);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  nextVideo.thumbnail.isNotEmpty
                      ? Image.network(
                          nextVideo.thumbnail,
                          width: 100,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 100,
                            height: 60,
                            color: const Color(0xFF2C2C2E),
                          ),
                        )
                      : Container(
                          width: 100,
                          height: 60,
                          color: const Color(0xFF2C2C2E),
                        ),
                  Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      nextVideo.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Guarda il prossimo",
                    style: TextStyle(
                      color: Color(0xFFFF3B30),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextVideo.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(CupertinoIcons.play_circle, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isYouTubeVideo = _youtubeId != null && _youtubeId!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800), 
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 20.0, bottom: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
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
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: isYouTubeVideo
                          ? YoutubePlayer(controller: _ytController)
                          : Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C1C1E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(CupertinoIcons.link, color: Colors.white, size: 32),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF3B30),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      final url = Uri.parse(widget.video.videoUrl);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      }
                                    },
                                    icon: const Icon(CupertinoIcons.play_arrow_solid, size: 16),
                                    label: const Text("Guarda sul sito TED"),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.video.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
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
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      widget.video.speakers, 
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.eye, color: Color(0xFF8E8E93), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          widget.video.views,
                          style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                        ),
                        const Text("  •  ", style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
                        Text(
                          widget.video.publishedDate, 
                          style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  _isLoadingRelated
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF3B30)))
                      : _relatedVideos.isNotEmpty
                          ? _buildWatchNextChip(_relatedVideos.first, isYouTubeVideo)
                          : const SizedBox.shrink(), 
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}