import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterPatientUseCase {
  final AuthRepository repository;

  RegisterPatientUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(Map<String, dynamic> data) =>
      repository.registerPatient(data);
}
