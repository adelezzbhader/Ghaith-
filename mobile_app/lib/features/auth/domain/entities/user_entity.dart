import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
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
  final String firstName;

  UserEntity({
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
    String? firstName,
  }) : firstName = firstName ?? fullName.split(' ').first;

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
