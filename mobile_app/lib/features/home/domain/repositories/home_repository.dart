import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/home/domain/entities/area_entity.dart';
import 'package:mongez/features/home/domain/entities/service_entity.dart';
import 'package:mongez/features/home/domain/entities/stats_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<ServiceEntity>>> getServices();
  Future<Either<Failure, List<AreaEntity>>> getAreas();
  Future<Either<Failure, StatsEntity>> getStats();
}
