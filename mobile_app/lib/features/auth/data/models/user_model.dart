import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? address;
  final String? gender;
  final String role;
  final double? rating;
  final int? totalVisits;
  final double? monthlyEarnings;
  final String? wallet;
  final String? firstName;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.address,
    this.gender,
    required this.role,
    this.rating,
    this.totalVisits,
    this.monthlyEarnings,
    this.wallet,
    this.firstName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? firstName;
    if (json['first_name'] != null) {
      firstName = json['first_name'] as String;
    }
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? json['phone_number'] as String?,
      address: json['address'] as String?,
      gender: json['gender'] as String?,
      role: (json['role'] as String? ?? json['user_type'] as String? ?? 'patient').toLowerCase(),
      rating: (json['rating'] as num?)?.toDouble(),
      totalVisits: json['total_visits'] as int? ?? json['visits_count'] as int?,
      monthlyEarnings: (json['monthly_earnings'] as num?)?.toDouble(),
      wallet: json['wallet'] as String?,
      firstName: firstName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      'role': role,
      'rating': rating,
      'total_visits': totalVisits,
      'monthly_earnings': monthlyEarnings,
      'wallet': wallet,
      'first_name': firstName,
    };
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
        gender: gender,
        role: role,
        rating: rating,
        totalVisits: totalVisits,
        monthlyEarnings: monthlyEarnings,
        wallet: wallet,
        firstName: firstName,
      );

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        fullName: entity.fullName,
        email: entity.email,
        phone: entity.phone,
        address: entity.address,
        gender: entity.gender,
        role: entity.role,
        rating: entity.rating,
        totalVisits: entity.totalVisits,
        monthlyEarnings: entity.monthlyEarnings,
        wallet: entity.wallet,
        firstName: entity.firstName,
      );

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        address,
        gender,
        role,
        rating,
        totalVisits,
        monthlyEarnings,
        wallet,
        firstName,
      ];
}
