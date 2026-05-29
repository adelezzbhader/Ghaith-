import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/patient/domain/entities/order_entity.dart';
import 'package:mongez/features/patient/domain/repositories/patient_repository.dart';

class CancelOrderUseCase {
  final PatientRepository repository;

  CancelOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String id) {
    return repository.cancelOrder(id);
  }
}
