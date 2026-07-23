import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyWatched = 'fixed_watched_ids';

  Future<Set<String>> getWatchedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyWatched) ?? [];
    return list.toSet();
  }

  Future<void> addWatchedVideo(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final watched = prefs.getStringList(_keyWatched) ?? [];
    if (!watched.contains(id)) {
      watched.add(id);
      await prefs.setStringList(_keyWatched, watched);
    }
  }

  Future<void> saveVideoProgress(String videoId, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('progress_$videoId', progress);
  }

  Future<double> getVideoProgress(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('progress_$videoId') ?? 0.0;
  }
}