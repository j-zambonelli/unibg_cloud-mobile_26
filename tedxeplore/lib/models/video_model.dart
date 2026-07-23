class TedVideo {
  final String id;
  final String title;
  final String speakers;
  final String thumbnail;
  final String duration;
  final String views;
  final String publishedDate;
  final String videoUrl;

  TedVideo({
    required this.id,
    required this.title,
    required this.speakers,
    required this.thumbnail,
    required this.duration,
    required this.views,
    required this.publishedDate,
    required this.videoUrl,
  });

  factory TedVideo.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    final title = json['title']?.toString() ?? '';
    
    final speakers = json['speakers']?.toString() ?? 
                     json['speaker']?.toString() ?? 
                     json['presenterDisplayName']?.toString() ?? '';
    
    final uniqueId = rawId.isNotEmpty ? rawId : '${title}_$speakers'.hashCode.toString();

    final durationRaw = json['duration'];
    final durationStr = durationRaw != null ? durationRaw.toString() : '';

    final viewsRaw = json['views'] ?? json['viewedCount'];
    final viewsStr = viewsRaw != null ? viewsRaw.toString() : '';

    String dateStr = '';
    if (json['publishedAt'] != null) {
      final rawDate = json['publishedAt'].toString();
      dateStr = rawDate.contains('T') ? rawDate.split('T')[0] : rawDate;
    }

    final String realVideoUrl = json['url']?.toString() ?? 
                                json['videoUrl']?.toString() ?? 
                                'https://www.ted.com/talks/$rawId';

    return TedVideo(
      id: uniqueId,
      title: title,
      speakers: speakers,
      thumbnail: json['thumbnail']?.toString() ?? json['image']?.toString() ?? '',
      duration: durationStr,
      views: viewsStr,
      publishedDate: dateStr,
      videoUrl: realVideoUrl,
    );
  }
}