import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/anime_model.dart';
import 'user_provider.dart';
import '../utils/constants.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<AnimeModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  await Future.delayed(AppDurations.searchDebounce);

  final firestore = ref.read(firestoreServiceProvider);
  final snapshot = await firestore.searchAnime(query.trim());
  return snapshot.docs.map((doc) => AnimeModel.fromFirestore(doc)).toList();
});
