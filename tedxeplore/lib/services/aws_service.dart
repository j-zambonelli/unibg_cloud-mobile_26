import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import '../models/profile_model.dart';

class AwsService {
  // Il nuovo Invoke URL ufficiale e corretto della tua API Gateway
  static const String _baseUrl = 'https://d07rge2bdi.execute-api.us-east-1.amazonaws.com/prod';

  // 1. PROFILO UTENTE: Recupero reale da AWS API Gateway
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
      } else {
        print('Errore API Profilo: ${response.statusCode}');
        print('Corpo risposta Profilo: ${response.body}');
      }
    } catch (e) {
      print('Eccezione di rete Profilo: $e');
    }

    // Fallback neutro di sicurezza con campi vuoti se il server risponde errore
    return UserProfileData(
      username: "",
      email: "",
      percentualiGeneri: {},
    );
  }

  // 2. SUGGERITI / PROPOSTE: Interroga l'endpoint passandogli i tag dei generi Kindle preferiti
  Future<List<TedVideo>> fetchRecommendedVideos(List<String> searchTags) async {
    final url = Uri.parse('$_baseUrl/recommended');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'search_tags': searchTags}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> dataList;

        if (decoded is List) {
          dataList = decoded;
        } else if (decoded is Map && decoded.containsKey('body')) {
          final inner = decoded['body'];
          dataList = inner is String ? jsonDecode(inner) : inner;
        } else {
          dataList = [];
        }

        return dataList.map((json) => TedVideo.fromJson(json)).toList();
      } else {
        print('Errore API Consigliati: ${response.statusCode}');
        print('Corpo risposta Consigliati: ${response.body}');
      }
    } catch (e) {
       print('Eccezione di rete Consigliati: $e');
    }

    // Ritorna una lista vuota reale in caso di fallimento di rete
    return [];
  }

  // 3. NOVITÀ DELLA SETTIMANA: Solo chiamata reale ad AWS senza alcuna simulazione
  Future<List<TedVideo>> fetchLatestVideos() async {
    final url = Uri.parse('$_baseUrl/latest');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> dataList;

        if (decoded is List) {
          dataList = decoded;
        } else if (decoded is Map && decoded.containsKey('body')) {
          final inner = decoded['body'];
          dataList = inner is String ? jsonDecode(inner) : inner;
        } else {
          dataList = [];
        }

        return dataList.map((json) => TedVideo.fromJson(json)).toList();
      } else {
        print('Errore API Latest: ${response.statusCode}');
        print('Corpo risposta Latest: ${response.body}');
      }
    } catch (e) {
      print('Eccezione di rete Latest: $e');
    }

    // Ritorna una lista vuota reale in caso di fallimento di rete
    return [];
  }
}