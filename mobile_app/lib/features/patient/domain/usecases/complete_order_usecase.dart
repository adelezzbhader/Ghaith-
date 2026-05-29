import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/patient/domain/entities/order_entity.dart';
import 'package:mongez/features/patient/domain/repositories/patient_repository.dart';

class CompleteOrderUseCase {
  final PatientRepository repository;

  CompleteOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String id) {
    return repository.completeOrder(id);
  }
}
