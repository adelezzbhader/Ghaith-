import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/patient/domain/repositories/patient_repository.dart';

class UpdateAddressUseCase {
  final PatientRepository repository;

  UpdateAddressUseCase(this.repository);

  Future<Either<Failure, PatientProfile>> call(String address) {
    return repository.updateAddress(address);
  }
}
