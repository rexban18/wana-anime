import 'package:cloud_firestore/cloud_firestore.dart';

class AnimeModel {
  final String id;
  final String title;
  final String description;
  final String coverImage;
  final bool isTrending;
  final String genre;
  final String rating;
  final int totalEpisodes;
  final bool recentlyUpdated;
  final DateTime createdAt;

  AnimeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    this.isTrending = false,
    this.genre = '',
    this.rating = '0.0',
    this.totalEpisodes = 0,
    this.recentlyUpdated = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AnimeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnimeModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      coverImage: data['coverImage'] as String? ?? '',
      isTrending: data['isTrending'] as bool? ?? false,
      genre: data['genre'] as String? ?? '',
      rating: data['rating'] as String? ?? '0.0',
      totalEpisodes: data['totalEpisodes'] as int? ?? 0,
      recentlyUpdated: data['recentlyUpdated'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'coverImage': coverImage,
      'isTrending': isTrending,
      'genre': genre,
      'rating': rating,
      'totalEpisodes': totalEpisodes,
      'recentlyUpdated': recentlyUpdated,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
