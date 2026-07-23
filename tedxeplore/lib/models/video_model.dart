class TedVideo {
  final String id;
  final String title;
  final String speaker;
  final String thumbnail;
  final String duration;
  final String views;
  final int year;
  final String videoUrl;

  TedVideo({
    required this.id,
    required this.title,
    required this.speaker,
    required this.thumbnail,
    required this.duration,
    required this.views,
    required this.year,
    required this.videoUrl,
  });

  factory TedVideo.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    final title = json['title']?.toString() ?? 'TEDx Talk';
    final speaker = json['speaker']?.toString() ?? json['presenterDisplayName']?.toString() ?? 'TEDx Speaker';
    
    final uniqueId = rawId.isNotEmpty ? rawId : '${title}_$speaker'.hashCode.toString();

    final durationRaw = json['duration'];
    final durationStr = durationRaw != null ? durationRaw.toString() : '';

    final viewsRaw = json['views'] ?? json['viewedCount'];
    final viewsStr = viewsRaw != null ? viewsRaw.toString() : '0 visti';

    // Estrae l'URL reale e dinamico del talk
    final String realVideoUrl = json['url']?.toString() ?? 
                                json['videoUrl']?.toString() ?? 
                                'https://www.ted.com/talks/$rawId';

    return TedVideo(
      id: uniqueId,
      title: title,
      speaker: speaker,
      thumbnail: json['thumbnail']?.toString() ?? json['image']?.toString() ?? '',
      duration: durationStr,
      views: viewsStr,
      year: json['year'] is int 
          ? json['year'] 
          : int.tryParse(json['year']?.toString()?.substring(0, 4) ?? '2026') ?? 2026,
      videoUrl: realVideoUrl,
    );
  }
}