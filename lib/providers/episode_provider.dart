import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/episode_model.dart';
import '../services/rtdb_service.dart';
import 'user_provider.dart';

final rtdbServiceProvider = Provider<RtdbService>((ref) {
  return RtdbService();
});

final episodesProvider = FutureProvider.family<List<EpisodeModel>, String>((ref, animeId) {
  final rtdb = ref.read(rtdbServiceProvider);
  return rtdb.getEpisodes(animeId);
});

final episodeDetailProvider = FutureProvider.family<EpisodeModel?, String>((ref, episodeId) {
  final rtdb = ref.read(rtdbServiceProvider);
  return rtdb.getEpisode(episodeId);
});
