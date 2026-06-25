import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import '../models/profile_model.dart';

class AwsService {
  // Il tuo Invoke URL ufficiale della TedxploreAPI su AWS Gateway
  static const String _baseUrl = 'https://vx1psjknmb.execute-api.us-east-1.amazonaws.com/prod';

  /// 1. PROFILO UTENTE: Recupero reale da AWS API Gateway
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

    // Fallback neutro di sicurezza con campi vuoti se il server risponde errore
    return UserProfileData(
      username: "",
      email: "",
      percentualiGeneri: {},
    );
  }

  /// 2. SUGGERITI / PROPOSTE: Interroga l'endpoint passandogli i tag dei generi Kindle preferiti
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

    // Ritorna una lista vuota reale in caso di fallimento di rete
    return [];
  }

  /// 3. NOVITÀ DELLA SETTIMANA: Solo chiamata reale ad AWS senza alcuna simulazione
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

    // Ritorna una lista vuota reale in caso di fallimento di rete
    return [];
  }
}