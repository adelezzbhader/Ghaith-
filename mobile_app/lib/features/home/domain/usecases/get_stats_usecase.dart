import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/home/domain/entities/stats_entity.dart';
import 'package:mongez/features/home/domain/repositories/home_repository.dart';

class GetStatsUseCase {
  final HomeRepository repository;

  GetStatsUseCase(this.repository);

  Future<Either<Failure, StatsEntity>> call() {
    return repository.getStats();
  }
}
