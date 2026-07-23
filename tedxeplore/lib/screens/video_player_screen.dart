import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isWebLink = false;

  @override
  void initState() {
    super.initState();
    _storageService.addWatchedVideo(widget.video.id);

    // Controlla se l'URL è una pagina web di TED o non è un file mp4 diretto
    if (widget.video.videoUrl.contains('ted.com') || !widget.video.videoUrl.endsWith('.mp4')) {
      setState(() {
        _isWebLink = true;
      });
    } else {
      _initVideoPlayer();
    }
  }

  void _initVideoPlayer() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller?.setVolume(1.0);
          _controller?.play();
        }
      }).catchError((error) {
        debugPrint("Errore flusso video, fallback a visualizzazione web: $error");
        setState(() {
          _isWebLink = true;
        });
      });
  }

  void _togglePlayPause() {
    if (_controller != null && _isInitialized) {
      setState(() {
        _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
      });
    }
  }

  Future<void> _openWebTalk() async {
    final Uri url = Uri.parse(widget.video.videoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    }
  }

  void _onClosePlayer() {
    _controller?.pause();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double calculatedProgress = 0.0;
    if (!_isWebLink && _isInitialized && _controller != null && _controller!.value.duration.inSeconds > 0) {
      calculatedProgress = (_controller!.value.position.inSeconds / _controller!.value.duration.inSeconds).clamp(0.0, 1.0);
    } else if (_isWebLink) {
      calculatedProgress = 0.5; // Progresso indicativo per i link web ufficiali
    }

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4), // Sfondo trasparente che mostra la home sotto
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
                  // Bottone di chiusura (X) in alto a destra
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

                  // Box del Player in-app (gestisce sia video diretto che pagina web ufficiale)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _isWebLink
                          ? GestureDetector(
                              onTap: _openWebTalk,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  widget.video.thumbnail.isNotEmpty
                                      ? Image.network(widget.video.thumbnail, width: double.infinity, fit: BoxFit.cover)
                                      : Container(color: Colors.grey[900]),
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
                                        "▶ Guarda il Talk ufficiale",
                                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : (_isInitialized && _controller != null
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    VideoPlayer(_controller!),
                                    GestureDetector(
                                      onTap: _togglePlayPause,
                                      child: Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _controller!.value.isPlaying 
                                              ? CupertinoIcons.pause_fill 
                                              : CupertinoIcons.play_fill, 
                                          color: Colors.white, 
                                          size: 36,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: LinearProgressIndicator(
                                        value: calculatedProgress,
                                        backgroundColor: Colors.white24,
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF3B30)),
                                        minHeight: 4,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  color: Colors.black,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(color: Color(0xFFFF3B30)),
                                )),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Dettagli del Talk
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
                  Text(
                    widget.video.speaker,
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Informazioni sul Talk",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Questo talk esplora idee innovative e prospettive uniche, connettendo teoria e pratica per stimolare la riflessione culturale.",
                    style: TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 14,
                      height: 1.4,
                    ),
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