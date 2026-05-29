import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/patient/domain/repositories/patient_repository.dart';

class GetPatientProfileUseCase {
  final PatientRepository repository;

  GetPatientProfileUseCase(this.repository);

  Future<Either<Failure, PatientProfile>> call() {
    return repository.getProfile();
  }
}
