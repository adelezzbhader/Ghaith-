import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mongez/core/errors/api_error_parser.dart';
import 'package:mongez/core/errors/exceptions.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/patient/data/datasources/patient_remote_data_source.dart';
import 'package:mongez/features/patient/domain/entities/order_entity.dart';
import 'package:mongez/features/patient/domain/repositories/patient_repository.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource _remoteDataSource;

  PatientRepositoryImpl(this._remoteDataSource);

  Failure _fromServerException(ServerException e) {
    return ServerFailure(e.message, fieldErrors: e.fieldErrors);
  }

  Failure _fromGenericException(Object e) {
    final parsed = e is DioException
        ? ApiErrorParser.fromDioError(e)
        : ApiErrorParser.fromException(e as Exception);
    return ServerFailure(parsed.generalMessage, fieldErrors: parsed.fieldErrors);
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() async {
    try {
      final models = await _remoteDataSource.getOrders();
      return Right(models);
    } on ServerException catch (e) {
      return Left(_fromServerException(e));
    } catch (e) {
      return Left(_fromGenericException(e));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required String areaId,
    required String address,
    required List<String> services,
    int? fullCareHours,
    String? fullCareGender,
  }) async {
    try {
      final model = await _remoteDataSource.createOrder(
        areaId: areaId,
        address: address,
        services: services,
        fullCareHours: fullCareHours,
        fullCareGender: fullCareGender,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(_fromServerException(e));
    } catch (e) {
      return Left(_fromGenericException(e));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> completeOrder(String id) async {
    try {
      final model = await _remoteDataSource.completeOrder(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(_fromServerException(e));
    } catch (e) {
      return Left(_fromGenericException(e));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> cancelOrder(String id) async {
    try {
      final model = await _remoteDataSource.cancelOrder(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(_fromServerException(e));
    } catch (e) {
      return Left(_fromGenericException(e));
    }
  }

  @override
  Future<Either<Failure, void>> rateOrder(String id, {required int score, String? comment}) async {
    try {
      await _remoteDataSource.rateOrder(id, score: score, comment: comment);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(_fromServerException(e));
    } catch (e) {
      return Left(_fromGenericException(e));
    }
  }

  @override
  Future<Either<Failure, PatientProfile>> getProfile() async {
    try {
      final data = await _remoteDataSource.getProfile();
      return Right(PatientProfile(
        name: data['full_name'] ?? data['name'] ?? '',
        phone: data['phone'] ?? '',
        email: data['email'] ?? '',
        gender: data['gender'],
        address: data['address'] ?? '',
      ));
    } on ServerException catch (e) {
      return Left(_fromServerException(e));
    } catch (e) {
      return Left(_fromGenericException(e));
    }
  }

  @override
  Future<Either<Failure, PatientProfile>> updateAddress(String address) async {
    try {
      final data = await _remoteDataSource.updateAddress(address);
      return Right(PatientProfile(
        name: data['full_name'] ?? data['name'] ?? '',
        phone: data['phone'] ?? '',
        email: data['email'] ?? '',
        gender: data['gender'],
        address: data['address'] ?? '',
      ));
    } on ServerException catch (e) {
      return Left(_fromServerException(e));
    } catch (e) {
      return Left(_fromGenericException(e));
    }
  }
}
