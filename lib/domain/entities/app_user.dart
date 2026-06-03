import 'package:equatable/equatable.dart';

/// Core User domain entity — clean, framework-free
class AppUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final int totalRecordings;
  final double averageScore;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.totalRecordings = 0,
    this.averageScore = 0.0,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    int? totalRecordings,
    double? averageScore,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      totalRecordings: totalRecordings ?? this.totalRecordings,
      averageScore: averageScore ?? this.averageScore,
    );
  }

  @override
  List<Object?> get props => [id, email];

  @override
  String toString() => 'AppUser(id: $id, name: $name, email: $email)';
}
