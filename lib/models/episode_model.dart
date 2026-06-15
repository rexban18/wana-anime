class EpisodeModel {
  final String id;
  final String animeId;
  final int episodeNumber;
  final String title;
  final bool isFree;
  final List<String> servers;
  final DateTime createdAt;

  EpisodeModel({
    required this.id,
    required this.animeId,
    required this.episodeNumber,
    required this.title,
    this.isFree = true,
    required this.servers,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory EpisodeModel.fromRtdb(Map<String, dynamic> data, String id) {
    final serversRaw = data['servers'];
    List<String> serversList = [];
    if (serversRaw is List) {
      serversList = serversRaw.cast<String>();
    } else if (serversRaw is Map) {
      serversList = (serversRaw as Map).values.cast<String>().toList();
    }

    return EpisodeModel(
      id: id,
      animeId: data['animeId'] as String? ?? '',
      episodeNumber: (data['episodeNumber'] as num?)?.toInt() ?? 0,
      title: data['title'] as String? ?? 'Episode ${data['episodeNumber'] ?? ''}',
      isFree: data['isFree'] as bool? ?? true,
      servers: serversList,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toRtdb() {
    return {
      'animeId': animeId,
      'episodeNumber': episodeNumber,
      'title': title,
      'isFree': isFree,
      'servers': servers,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
