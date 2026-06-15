import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final userProvider = AsyncNotifierProvider<UserNotifier, UserModel?>(UserNotifier.new);

class UserNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final authUser = ref.watch(authServiceProvider).currentUser;
    if (authUser == null) return null;

    final firestore = ref.read(firestoreServiceProvider);
    final user = await firestore.getUser(authUser.uid);
    return user;
  }

  Future<void> fetchUser(String uid) async {
    state = const AsyncValue.loading();
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final user = await firestore.getUser(uid);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      await firestore.createUser(user);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    final current = state.valueOrNull;
    if (current == null) return;

    try {
      final firestore = ref.read(firestoreServiceProvider);
      await firestore.updateUser(current.uid, data);
      final updated = await firestore.getUser(current.uid);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
