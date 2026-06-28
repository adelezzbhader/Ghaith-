import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/exceptions.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/home/data/datasources/home_remote_data_source.dart';
import 'package:mongez/features/home/domain/entities/area_entity.dart';
import 'package:mongez/features/home/domain/entities/service_entity.dart';
import 'package:mongez/features/home/domain/entities/stats_entity.dart';
import 'package:mongez/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServices() async {
    try {
      final models = await _remoteDataSource.getServices();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, fieldErrors: e.fieldErrors));
    }
  }

  @override
  Future<Either<Failure, List<AreaEntity>>> getAreas() async {
    try {
      final models = await _remoteDataSource.getAreas();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, fieldErrors: e.fieldErrors));
    }
  }

  @override
  Future<Either<Failure, StatsEntity>> getStats() async {
    try {
      final model = await _remoteDataSource.getStats();
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, fieldErrors: e.fieldErrors));
    }
  }
}
