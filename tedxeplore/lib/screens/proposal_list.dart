import 'package:flutter/material.dart';
import '../components/video_card.dart';
import '../models/profile_model.dart';
import '../models/video_model.dart';
import '../services/aws_service.dart';

class ProposalsScreen extends StatefulWidget {
  final List<String> favoriteIds;
  final Function(String) onToggleFavorite;
  final UserProfileData userProfile; 

  const ProposalsScreen({
    super.key, 
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.userProfile,
  });

  @override
  State<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen> {
  final AwsService _awsService = AwsService();
  List<TedVideo> _allProposals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllProposalsFromAWS();
  }

  Future<void> _loadAllProposalsFromAWS() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final List<String> userTags = [];
      
      widget.userProfile.percentualiGeneri.forEach((key, value) {
        if (key == 'Scienza') userTags.addAll(['science', 'biology', 'nature', 'animals']);
        if (key == 'Tecnologia e Ingegneria') userTags.addAll(['technology', 'innovation', 'future', 'engineering', 'computers']);
        if (key == 'Medicina e Corpo umano') userTags.addAll(['health', 'medicine', 'brain', 'health care', 'human body']);
        if (key == 'Core') userTags.addAll(['business', 'work', 'economics', 'history', 'education']);
        if (key == 'Crescita professionale') userTags.addAll(['leadership', 'collaboration', 'marketing']);
        if (key == 'Mente e Comportamento') userTags.addAll(['psychology', 'brain', 'identity']);
        if (key == 'Sviluppo personale') userTags.addAll(['personal growth', 'creativity', 'storytelling']);
        if (key == 'Società e cultura') userTags.addAll(['social change', 'culture', 'society', 'humanity', 'community']);
        if (key == 'Politica e istruzione') userTags.addAll(['politics', 'government', 'activism', 'women']);
        if (key == 'Ambiente e sostenibilità') userTags.addAll(['climate change', 'environment', 'sustainability', 'Countdown']);
        if (key == 'Scenari globali') userTags.addAll(['global issues']);
        if (key == 'Narrazione') userTags.addAll(['humanity', 'identity']);
        if (key == 'Arti visive e performative') userTags.addAll(['design', 'art', 'entertainment', 'music', 'performance']);
        if (key == 'Contenuti multimediali') userTags.addAll(['animation', 'media']);
      });

      final videos = await _awsService.fetchRecommendedVideos(userTags);
      
      if (mounted) {
        setState(() {
          _allProposals = videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("[DEBUG PROPOSTE SCREEN] Errore di connessione: $e");
      if (mounted) {
        setState(() {
          _allProposals = [];
          _isLoading = false; 
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tutte le Proposte', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
            )
          : _allProposals.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, color: Color(0xFF48484A), size: 48),
                        SizedBox(height: 12),
                        Text(
                          "Nessuna proposta disponibile al momento",
                          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    itemCount: _allProposals.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.73,
                    ),
                    itemBuilder: (context, index) {
                      final video = _allProposals[index];
                      return TedxVideoCard(
                        title: video.title,
                        speaker: video.speaker,
                        imageUrl: video.thumbnail,
                        duration: video.duration,
                        views: video.views,
                        year: video.year.toString(),
                        isFavorite: widget.favoriteIds.contains(video.id),
                        onTap: () {},
                        onToggleFavorite: () => widget.onToggleFavorite(video.id),
                      );
                    },
                  ),
                ),
    );
  }
}