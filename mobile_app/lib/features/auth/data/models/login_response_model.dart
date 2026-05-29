import 'user_model.dart';

class LoginResponseModel {
  final String access;
  final String? refresh;
  final UserModel user;

  LoginResponseModel({required this.access, this.refresh, required this.user});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        access: json['access'] ?? '',
        refresh: json['refresh'],
        user: UserModel.fromJson(json['user'] ?? {}),
      );
}
