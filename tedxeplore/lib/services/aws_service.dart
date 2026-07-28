import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import '../models/profile_model.dart';

class AwsService {
  static const String _baseUrl = 'https://d07rge2bdi.execute-api.us-east-1.amazonaws.com/prod';

  // 1. USER PROFILE
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

    return UserProfileData(
      username: "",
      email: "",
      percentualiGeneri: {},
    );
  }

  // 2. RECOMMENDATIONS
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

    return [];
  }

  // 3. LATEST VIDEOS published in the last week
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

    return [];
  }

  // 4. LIKES (GET) 
  Future<List<TedVideo>> fetchFavoriteVideos(String token) async {
    final url = Uri.parse('$_baseUrl/favorites');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> dataList = [];

        if (decoded is List) {
          dataList = decoded;
        } else if (decoded is Map) {
          if (decoded.containsKey('body')) {
            final inner = decoded['body'];
            if (inner is String) {
              final parsedInner = jsonDecode(inner);
              dataList = parsedInner is List ? parsedInner : [];
            } else if (inner is List) {
              dataList = inner;
            }
          } else if (decoded.containsKey('videos')) {
            dataList = decoded['videos'] is List ? decoded['videos'] : [];
          }
        }

        return dataList.map((json) => TedVideo.fromJson(json)).toList();
      } else {
        print('Errore API Fetch Preferiti: ${response.statusCode}');
      }
    } catch (e) {
      print('Eccezione di rete Fetch Preferiti: $e');
    }
    return [];
  }

  // 5. LIKE (POST)
  Future<void> toggleFavoriteApi(String token, String videoId) async {
    final url = Uri.parse('$_baseUrl/favorites');
    try {
      await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'videoId': videoId}),
      );
    } catch (e) {
      print('Eccezione di rete Toggle Preferito API: $e');
    }
  }

  // 6. WATCH NEXT 
  Future<List<TedVideo>> fetchWatchNextVideos(String videoId, String videoTitle) async {
    final url = Uri.parse('$_baseUrl/watch-next'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'current_video_id': videoId,
          'current_video_title': videoTitle
        }),
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
        print('Errore API Watch Next: ${response.statusCode}');
        print('Corpo risposta Watch Next: ${response.body}');
      }
    } catch (e) {
      print('Eccezione di rete Watch Next: $e');
    }

    return [];
  }
}