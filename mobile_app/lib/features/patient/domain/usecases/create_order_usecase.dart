import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/patient/domain/entities/order_entity.dart';
import 'package:mongez/features/patient/domain/repositories/patient_repository.dart';

class CreateOrderUseCase {
  final PatientRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call({
    required String areaId,
    required String address,
    required List<String> services,
    int? fullCareHours,
    String? fullCareGender,
  }) {
    return repository.createOrder(
      areaId: areaId,
      address: address,
      services: services,
      fullCareHours: fullCareHours,
      fullCareGender: fullCareGender,
    );
  }
}
