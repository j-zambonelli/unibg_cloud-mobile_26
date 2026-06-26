class TedVideo {
  final String id;
  final String title;
  final String speaker;
  final String thumbnail;
  final String duration;
  final String views;
  final int year;

  TedVideo({
    required this.id,
    required this.title,
    required this.speaker,
    required this.thumbnail,
    required this.duration,
    required this.views,
    required this.year,
  });

  factory TedVideo.fromJson(Map<String, dynamic> json) {
    return TedVideo(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? 'TEDx Talk',
      speaker: json['speaker'] ?? 'TEDx Speaker',
      thumbnail: json['thumbnail']?.toString() ?? '',
      duration: json['duration'] ?? '',
      views: json['views'] ?? '',
      year: json['year'] is int ? json['year'] : int.tryParse(json['year']?.toString() ?? '2026') ?? 2026,
    );
  }
}