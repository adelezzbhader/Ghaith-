import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final Map<String, List<String>> fieldErrors;
  const Failure(this.message, {this.fieldErrors = const {}});
  @override
  List<Object?> get props => [message, fieldErrors];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.fieldErrors});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.fieldErrors});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
