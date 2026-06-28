import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String role;

  const LoginEvent({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, role];
}

class RegisterPatientEvent extends AuthEvent {
  final Map<String, dynamic> data;

  const RegisterPatientEvent({required this.data});

  @override
  List<Object?> get props => [data];
}

class RegisterNurseEvent extends AuthEvent {
  final Map<String, dynamic> data;
  final XFile? photo;
  final XFile? certificate;
  final XFile? syndicateCard;

  const RegisterNurseEvent({
    required this.data,
    this.photo,
    this.certificate,
    this.syndicateCard,
  });

  @override
  List<Object?> get props => [data, photo, certificate, syndicateCard];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}
