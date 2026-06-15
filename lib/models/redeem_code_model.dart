import 'package:cloud_firestore/cloud_firestore.dart';

class RedeemCodeModel {
  final String code;
  final String planType;
  final int durationDays;
  final bool isUsed;
  final String? usedBy;
  final Timestamp? usedAt;
  final DateTime createdAt;

  RedeemCodeModel({
    required this.code,
    required this.planType,
    required this.durationDays,
    this.isUsed = false,
    this.usedBy,
    this.usedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RedeemCodeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RedeemCodeModel(
      code: doc.id,
      planType: data['planType'] as String? ?? '1month',
      durationDays: data['durationDays'] as int? ?? 30,
      isUsed: data['isUsed'] as bool? ?? false,
      usedBy: data['usedBy'] as String?,
      usedAt: data['usedAt'] as Timestamp?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'planType': planType,
      'durationDays': durationDays,
      'isUsed': isUsed,
      'usedBy': usedBy,
      'usedAt': usedAt,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
