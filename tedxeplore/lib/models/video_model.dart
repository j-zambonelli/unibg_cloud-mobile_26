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
    // 1. Estrazione ID (gestisce sia documenti principali che sotto-oggetti correlati)
    final rawId =
        json['id']?.toString() ??
        json['_id']?.toString() ??
        json['related_id']?.toString() ??
        '';

    // 2. Estrazione Titolo
    final title =
        json['title']?.toString() ?? json['related_title']?.toString() ?? '';

    // 3. Estrazione Speaker/Relatore
    final speakers =
        json['speakers']?.toString() ??
        json['speaker']?.toString() ??
        json['presenterDisplayName']?.toString() ??
        '';

    // Genera un ID univoco di fallback se manca l'ID originale
    final uniqueId = rawId.isNotEmpty
        ? rawId
        : '${title}_$speakers'.hashCode.toString();

    // 4. Estrazione e Fallback per la Thumbnail
    String rawThumb =
        json['thumbnail']?.toString() ??
        json['image']?.toString() ??
        json['url_thumbnail']?.toString() ??
        '';

    // Se l'immagine manca (es. nei caricamenti a catena), applica una miniatura predefinita
    if (rawThumb.isEmpty) {
      rawThumb =
          "https://pi.tedcdn.com/r/talkstar-photos.s3.amazonaws.com/uploads/72bda89f-8bbf-4685-910a-2f151c4f0762/BillGates_2015-embed.jpg";
    }

    // 5. Formattazione Durata (converte da secondi in formato MM:SS se necessario)
    String formattedDuration = '';
    final durationRaw = json['duration'] ?? json['related_duration'];

    if (durationRaw != null) {
      String rawStr = durationRaw.toString();
      if (rawStr.contains(':')) {
        formattedDuration = rawStr;
      } else {
        int? totalSeconds = int.tryParse(rawStr);
        if (totalSeconds != null) {
          int minutes = totalSeconds ~/ 60;
          int seconds = totalSeconds % 60;
          formattedDuration = '$minutes:${seconds.toString().padLeft(2, '0')}';
        } else {
          formattedDuration = rawStr;
        }
      }
    }

    // 6. Visualizzazioni
    final viewsRaw = json['views'] ?? json['viewedCount'];
    final viewsStr = viewsRaw != null ? viewsRaw.toString() : '';

    // 7. Data di Pubblicazione
    String dateStr = '';
    if (json['publishedAt'] != null) {
      final rawDate = json['publishedAt'].toString();
      dateStr = rawDate.contains('T') ? rawDate.split('T')[0] : rawDate;
    }

    // 8. URL del Video TED
    final String realVideoUrl =
        json['url']?.toString() ??
        json['videoUrl']?.toString() ??
        (json['related_slug'] != null
            ? 'https://www.ted.com/talks/${json['related_slug']}'
            : 'https://www.ted.com/talks/$rawId');

    return TedVideo(
      id: uniqueId,
      title: title,
      speakers: speakers,
      thumbnail: rawThumb,
      duration: formattedDuration,
      views: viewsStr,
      publishedDate: dateStr,
      videoUrl: realVideoUrl,
    );
  }
}
