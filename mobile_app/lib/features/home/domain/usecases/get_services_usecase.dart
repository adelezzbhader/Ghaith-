import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/home/domain/entities/service_entity.dart';
import 'package:mongez/features/home/domain/repositories/home_repository.dart';

class GetServicesUseCase {
  final HomeRepository repository;

  GetServicesUseCase(this.repository);

  Future<Either<Failure, List<ServiceEntity>>> call() {
    return repository.getServices();
  }
}
