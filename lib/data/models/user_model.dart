import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apex_speech/domain/entities/app_user.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final int totalRecordings;
  final double averageScore;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.totalRecordings = 0,
    this.averageScore = 0.0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      totalRecordings: data['totalRecordings'] as int? ?? 0,
      averageScore: (data['averageScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory UserModel.fromEntity(AppUser user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt,
      totalRecordings: user.totalRecordings,
      averageScore: user.averageScore,
    );
  }

  AppUser toEntity() {
    return AppUser(
      id: id,
      name: name,
      email: email,
      createdAt: createdAt,
      totalRecordings: totalRecordings,
      averageScore: averageScore,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalRecordings': totalRecordings,
      'averageScore': averageScore,
    };
  }
}
