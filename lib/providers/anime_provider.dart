import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/anime_model.dart';
import 'user_provider.dart';

final animeListProvider = StreamProvider<List<AnimeModel>>((ref) {
  final firestore = ref.read(firestoreServiceProvider);
  return firestore.getAnimeStream().map((snapshot) {
    return snapshot.docs.map((doc) => AnimeModel.fromFirestore(doc)).toList();
  });
});

final trendingProvider = StreamProvider<List<AnimeModel>>((ref) {
  final firestore = ref.read(firestoreServiceProvider);
  return firestore.getTrendingStream().map((snapshot) {
    return snapshot.docs.map((doc) => AnimeModel.fromFirestore(doc)).toList();
  });
});

final liveUploadsProvider = StreamProvider<List<AnimeModel>>((ref) {
  final firestore = ref.read(firestoreServiceProvider);
  return firestore.getRecentlyAddedStream().map((snapshot) {
    return snapshot.docs.map((doc) => AnimeModel.fromFirestore(doc)).toList();
  });
});

final animeDetailProvider = FutureProvider.family<AnimeModel?, String>((ref, id) {
  final firestore = ref.read(firestoreServiceProvider);
  return firestore.getAnime(id);
});
