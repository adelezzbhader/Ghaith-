import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/home/domain/entities/area_entity.dart';
import 'package:mongez/features/home/domain/repositories/home_repository.dart';

class GetAreasUseCase {
  final HomeRepository repository;

  GetAreasUseCase(this.repository);

  Future<Either<Failure, List<AreaEntity>>> call() {
    return repository.getAreas();
  }
}
