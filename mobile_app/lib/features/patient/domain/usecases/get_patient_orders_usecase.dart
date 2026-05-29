import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/patient/domain/entities/order_entity.dart';
import 'package:mongez/features/patient/domain/repositories/patient_repository.dart';

class GetPatientOrdersUseCase {
  final PatientRepository repository;

  GetPatientOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call() {
    return repository.getOrders();
  }
}
