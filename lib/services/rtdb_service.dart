import 'package:firebase_database/firebase_database.dart';
import '../models/episode_model.dart';

class RtdbService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<List<EpisodeModel>> getEpisodes(String animeId) async {
    final snapshot = await _db.child('episodes').orderByChild('animeId').equalTo(animeId).get();
    if (!snapshot.exists) return [];

    final List<EpisodeModel> episodes = [];
    final data = snapshot.value as Map<dynamic, dynamic>;
    data.forEach((key, value) {
      episodes.add(EpisodeModel.fromRtdb(
        Map<String, dynamic>.from(value as Map),
        key as String,
      ));
    });
    episodes.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
    return episodes;
  }

  Future<EpisodeModel?> getEpisode(String episodeId) async {
    final snapshot = await _db.child('episodes').child(episodeId).get();
    if (!snapshot.exists) return null;
    return EpisodeModel.fromRtdb(
      Map<String, dynamic>.from(snapshot.value as Map),
      episodeId,
    );
  }
}
