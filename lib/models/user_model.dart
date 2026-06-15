import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool isPremium;
  final Timestamp? premiumExpiry;
  final String? planType;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.isPremium = false,
    this.premiumExpiry,
    this.planType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      isPremium: data['isPremium'] as bool? ?? false,
      premiumExpiry: data['premiumExpiry'] as Timestamp?,
      planType: data['planType'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'isPremium': isPremium,
      'premiumExpiry': premiumExpiry,
      'planType': planType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    bool? isPremium,
    Timestamp? premiumExpiry,
    String? planType,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
      planType: planType ?? this.planType,
      createdAt: createdAt,
    );
  }

  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumExpiry == null) return false;
    return premiumExpiry!.toDate().isAfter(DateTime.now());
  }
}
