import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/nurse_repository.dart';
import '../datasources/nurse_remote_data_source.dart';
import '../models/earnings_model.dart';
import '../models/nurse_order_model.dart';
import '../models/rating_model.dart';

class NurseRepositoryImpl implements NurseRepository {
  final NurseRemoteDataSource _remoteDataSource;

  NurseRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProfile() async {
    try {
      final result = await _remoteDataSource.getProfile();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, fieldErrors: e.fieldErrors));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NurseOrderModel>>> getActiveOrders() async {
    try {
      final result = await _remoteDataSource.getActiveOrders();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, fieldErrors: e.fieldErrors));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NurseOrderModel>>> getMyOrders() async {
    try {
      final result = await _remoteDataSource.getMyOrders();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, fieldErrors: e.fieldErrors));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, NurseOrderModel>> acceptOrder(String id) async {
    try {
      final result = await _remoteDataSource.acceptOrder(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, fieldErrors: e.fieldErrors));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, NurseOrderModel>> completeOrder(String id) async {
    try {
      final result = await _remoteDataSource.completeOrder(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, fieldErrors: e.fieldErrors));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String id) async {
    try {
      await _remoteDataSource.cancelOrder(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, fieldErrors: e.fieldErrors));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, EarningsModel>> getEarnings() async {
    try {
      final result = await _remoteDataSource.getEarnings();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, fieldErrors: e.fieldErrors));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RatingModel>>> getRatings() async {
    try {
      final result = await _remoteDataSource.getRatings();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, fieldErrors: e.fieldErrors));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStats() async {
    try {
      final result = await _remoteDataSource.getStats();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, fieldErrors: e.fieldErrors));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getServices() async {
    try {
      final result = await _remoteDataSource.getServices();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, fieldErrors: e.fieldErrors));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}
