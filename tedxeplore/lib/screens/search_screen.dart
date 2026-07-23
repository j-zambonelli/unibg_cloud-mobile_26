import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/aws_service.dart';
import '../components/video_card.dart';

class SearchScreen extends StatefulWidget {
  final List<String> favoriteIds;
  final List<String> watchedIds;
  final Function(String) onToggleFavorite;
  final Function(TedVideo) onVideoTap;

  const SearchScreen({
    super.key,
    required this.favoriteIds,
    required this.watchedIds,
    required this.onToggleFavorite,
    required this.onVideoTap,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AwsService _awsService = AwsService();
  final TextEditingController _searchController = TextEditingController();
  
  List<TedVideo> _allVideos = [];
  List<TedVideo> _filteredVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllVideos();
    _searchController.addListener(_filterVideos);
  }

  Future<void> _loadAllVideos() async {
    try {
      final videos = await _awsService.fetchRecommendedVideos([]);
      setState(() {
        _allVideos = videos;
        _filteredVideos = videos;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterVideos() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredVideos = _allVideos;
      });
      return;
    }

    setState(() {
      _filteredVideos = _allVideos.where((video) {
        final titleMatch = video.title.toLowerCase().contains(query);
        final speakerMatch = video.speakers.toLowerCase().contains(query);
        return titleMatch || speakerMatch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cerca Talk",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 16),
              
              // Barra di ricerca in stile iOS
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cerca per titolo, speaker...',
                  hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
                  prefixIcon: const Icon(CupertinoIcons.search, color: Color(0xFF8E8E93)),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Risultati
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF3B30)))
                    : _filteredVideos.isEmpty
                        ? const Center(
                            child: Text(
                              "Nessun talk trovato",
                              style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredVideos.length,
                            itemBuilder: (context, index) {
                              final video = _filteredVideos[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      video.thumbnail,
                                      width: 100,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    video.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    video.speakers,
                                    style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                                  ),
                                  onTap: () => widget.onVideoTap(video),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}