import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/anime_model.dart';
import '../models/redeem_code_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Users ───────────────────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toFirestore());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // ─── Anime ───────────────────────────────────────────────
  Stream<QuerySnapshot<Map<String, dynamic>>> getAnimeStream() {
    return _db
        .collection('anime')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTrendingStream() {
    return _db
        .collection('anime')
        .where('isTrending', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRecentlyAddedStream() {
    return _db
        .collection('anime')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<AnimeModel?> getAnime(String animeId) async {
    final doc = await _db.collection('anime').doc(animeId).get();
    if (!doc.exists) return null;
    return AnimeModel.fromFirestore(doc);
  }

  // ─── Search ──────────────────────────────────────────────
  Future<QuerySnapshot<Map<String, dynamic>>> searchAnime(String query) {
    final searchLower = query.toLowerCase();
    return _db
        .collection('anime')
        .orderBy('title')
        .startAt([searchLower])
        .endAt([searchLower + '\uf8ff'])
        .get();
  }

  // ─── Redeem Codes ────────────────────────────────────────
  Future<RedeemCodeModel?> getRedeemCode(String code) async {
    final doc = await _db.collection('redeemCodes').doc(code.trim().toUpperCase()).get();
    if (!doc.exists) return null;
    return RedeemCodeModel.fromFirestore(doc);
  }

  Future<void> markCodeUsed(String code, String userId) async {
    await _db.collection('redeemCodes').doc(code).update({
      'isUsed': true,
      'usedBy': userId,
      'usedAt': FieldValue.serverTimestamp(),
    });
  }
}
