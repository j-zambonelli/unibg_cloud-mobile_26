import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import '../models/profile_model.dart';

class AwsService {
  static const String _baseUrl = 'https://vx1psjknmb.execute-api.us-east-1.amazonaws.com/prod';

  Future<UserProfileData> fetchUserProfile(String token) async {
    final url = Uri.parse('$_baseUrl/user/profile');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return UserProfileData.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}

    return UserProfileData(
      username: "JuliaZ04",
      email: "julia.zambonelli@studenti.unibg.it",
      percentualiGeneri: {
        'Scienza': 0.25,
        'Tecnologia e Ingegneria': 0.35,
        'Ambiente e sostenibilità': 0.40,
      },
    );
  }

  Future<List<TedVideo>> fetchRecommendedVideos(List<String> searchTags) async {
    final url = Uri.parse('$_baseUrl/recommended');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'search_tags': searchTags}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TedVideo.fromJson(json)).toList();
      }
    } catch (_) {}

    return [
      TedVideo(
        id: "v1",
        title: "Il futuro dell'esplorazione spaziale e NASA NOS3",
        speaker: "Julia Zambonelli",
        thumbnail: "https://picsum.photos/seed/space/300/200",
        duration: "14:20",
        views: "1.2M",
        year: 2026,
      ),
      TedVideo(
        id: "v2",
        title: "Ingegneria del Software nel Cloud Computing",
        speaker: "UniBG Engineering",
        thumbnail: "https://picsum.photos/seed/cloud/300/200",
        duration: "18:15",
        views: "450K",
        year: 2025,
      ),
    ];
  }

  Future<List<TedVideo>> fetchLatestVideos() async {
    final url = Uri.parse('$_baseUrl/latest');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TedVideo.fromJson(json)).toList();
      }
    } catch (_) {}

    return [
      TedVideo(
        id: "new_1", 
        title: "L'impatto delle tempeste solari nel 2026", 
        speaker: "Space Lab", 
        thumbnail: "https://picsum.photos/seed/solar/300/200", 
        duration: "11:40", 
        views: "15K", 
        year: 2026,
      ),
    ];
  }
}