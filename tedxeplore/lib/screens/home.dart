import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'proposal_list.dart';
import '../components/genre_wheel.dart';
import '../components/genre_chips.dart';
import '../components/video_carousel.dart';
import '../models/profile_model.dart';
import '../models/video_model.dart';
import '../services/aws_service.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  final List<String> favoriteIds;
  final List<String> watchedIds;
  final Function(String) onToggleFavorite;
  final Function(TedVideo) onVideoTap;
  final UserProfileData userProfile;

  const HomeScreen({
    super.key,
    required this.favoriteIds,
    required this.watchedIds,
    required this.onToggleFavorite,
    required this.onVideoTap,
    required this.userProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AwsService _awsService = AwsService();
  String? _selectedGenreId;
  String genereSelezionatoNome = '';
  
  List<Map<String, dynamic>> generiData = [];
  List<TedVideo> _recommendedVideos = [];
  List<TedVideo> _latestVideos = [];
  
  bool _isCarouselLoading = true;
  bool _isLatestLoading = true;

  final Map<String, List<String>> _databaseTagsMappatura = {
    'Scienza': ['science', 'biology', 'nature', 'animals'],
    'Tecnologia e Ingegneria': ['technology', 'innovation', 'future', 'engineering', 'computers'],
    'Medicina e Corpo umano': ['health', 'medicine', 'brain', 'health care', 'human body'],
    'Core': ['business', 'work', 'economics', 'history', 'education'],
    'Crescita professionale': ['leadership', 'collaboration', 'marketing'],
    'Mente e Comportamento': ['psychology', 'brain', 'identity'],
    'Sviluppo personale': ['personal growth', 'creativity', 'storytelling'],
    'Società e cultura': ['social change', 'culture', 'society', 'humanity', 'community'],
    'Politica e istruzione': ['politics', 'government', 'activism', 'women'],
    'Ambiente e sostenibilità': ['climate change', 'environment', 'sustainability', 'Countdown'],
    'Scenari globali': ['global issues'], 
    'Narrazione': ['humanity', 'identity'],
    'Arti visive e performative': ['design', 'art', 'entertainment', 'music', 'performance'],
    'Contenuti multimediali': ['animation', 'media'],
  };

  @override
  void initState() {
    super.initState();
    _inizializzaGeneriElettivi();
    _loadLatestFormatVideos();
  }

  void _inizializzaGeneriElettivi() {
    int idCounter = 1;
    List<Map<String, dynamic>> temporanea = [];

    widget.userProfile.percentualiGeneri.forEach((nomeGenere, percentuale) {
      if (_databaseTagsMappatura.containsKey(nomeGenere)) {
        temporanea.add({
          'id': idCounter.toString(),
          'nome': nomeGenere,
          'tagDatabase': _databaseTagsMappatura[nomeGenere],
          'percentuale': percentuale,
        });
        idCounter++;
      }
    });

    temporanea.sort((a, b) => (b['percentuale'] as num).compareTo(a['percentuale'] as num));

    if (temporanea.isNotEmpty) {
      generiData = temporanea;
      _selectedGenreId = generiData.first['id'];
      genereSelezionatoNome = generiData.first['nome'];
      _loadVideosForSelectedGenre(generiData.first['tagDatabase']);
    } else {
      _loadVideosForSelectedGenre([]);
    }
  }

  Future<void> _loadVideosForSelectedGenre(List<String> tags) async {
    setState(() => _isCarouselLoading = true);
    try {
      final videos = await _awsService.fetchRecommendedVideos(tags);
      setState(() {
        _recommendedVideos = videos;
        _isCarouselLoading = false;
      });
    } catch (_) {
      setState(() {
        _recommendedVideos = [];
        _isCarouselLoading = false;
      });
    }
  }

  Future<void> _loadLatestFormatVideos() async {
    setState(() => _isLatestLoading = true);
    try {
      final videos = await _awsService.fetchLatestVideos();
      setState(() {
        _latestVideos = videos.take(10).toList();
        _isLatestLoading = false;
      });
    } catch (_) {
      setState(() {
        _latestVideos = [];
        _isLatestLoading = false;
      });
    }
  }

  Future<UserProfileData> _fetchCognitoUserProfile() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      
      String email = '';
      String username = '';

      final idToken = session.userPoolTokensResult.value.idToken;
      final Map<String, dynamic> claims = idToken.claims.toJson();

      email = claims['email'] ?? claims['custom:email'] ?? '';
      username = claims['preferred_username'] ?? claims['name'] ?? claims['cognito:username'] ?? '';

      if (username.isEmpty) {
        final authUser = await Amplify.Auth.getCurrentUser();
        username = authUser.username;
      }

      return UserProfileData(
        username: username.isNotEmpty ? username : widget.userProfile.username,
        email: email.isNotEmpty ? email : (widget.userProfile.email.isNotEmpty ? widget.userProfile.email : 'Email non disponibile'),
        percentualiGeneri: widget.userProfile.percentualiGeneri,
      );
    } catch (e) {
      safePrint('Errore nel recupero della sessione Cognito: $e');
      return widget.userProfile;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> listForComponents = generiData.map((g) {
      return <String, dynamic>{
        'id': g['id'],
        'name': g['nome'],
        'percentage': ((g['percentuale'] as double) * 100).toInt(),
      };
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con Logo e Profilo
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1.0),
                        children: [
                          TextSpan(text: "TED", style: TextStyle(color: Color(0xFFFF3B30))),
                          TextSpan(text: "xplore", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        UserProfileData profileToPass = await _fetchCognitoUserProfile();

                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                userProfile: profileToPass,
                                favoriteCount: widget.favoriteIds.length,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                        ),
                        child: const Icon(
                          CupertinoIcons.person_crop_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 14),
              Center(child: GenreWheel(genres: listForComponents, selectedGenreId: _selectedGenreId)),
              
              if (listForComponents.isEmpty) ...[
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Nessun genere Kindle rilevato",
                    style: TextStyle(
                      color: Color(0xFF8E8E93), 
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: GenreChips(
                    genres: listForComponents,
                    selectedGenreId: _selectedGenreId,
                    onSelectGenre: (id) {
                      final target = generiData.firstWhere((g) => g['id'] == id);
                      setState(() {
                        _selectedGenreId = id;
                        genereSelezionatoNome = target['nome'];
                      });
                      _loadVideosForSelectedGenre(List<String>.from(target['tagDatabase']));
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
              
              // Carosello 1: Consigliati / Scopri
              _isCarouselLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFFFF3B30))),
                    )
                  : VideoCarousel(
                      title: listForComponents.isNotEmpty ? "Suggeriti per te" : "Scopri nuovi video",
                      videos: _recommendedVideos,
                      showExpandButton: true,
                      favoriteIds: widget.favoriteIds,
                      watchedIds: widget.watchedIds, 
                      onToggleFavorite: widget.onToggleFavorite,
                      onVideoTap: widget.onVideoTap,  
                      onExpandPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (c) => ProposalsScreen(
                            favoriteIds: widget.favoriteIds,
                            onToggleFavorite: widget.onToggleFavorite,
                            userProfile: widget.userProfile,
                          ),
                        ),
                      ),
                    ),
              
              const SizedBox(height: 24),
              
              // Carosello 2: Novità della settimana
              _isLatestLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFFFF3B30))),
                    )
                  : VideoCarousel(
                      title: "Novità della settimana",
                      videos: _latestVideos,
                      favoriteIds: widget.favoriteIds,
                      watchedIds: widget.watchedIds,
                      onToggleFavorite: widget.onToggleFavorite,
                      onVideoTap: widget.onVideoTap,       
                    ),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}