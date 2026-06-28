import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongez/core/constants/app_constants.dart';
import 'package:mongez/core/errors/api_error_parser.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _storage;

  AuthRepositoryImpl(this._remoteDataSource, this._storage);

  Failure _fromDioException(DioException e) {
    final parsed = ApiErrorParser.fromDioError(e);
    final isNetwork = e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError;
    if (isNetwork) {
      return NetworkFailure(parsed.generalMessage);
    }
    if (e.response?.statusCode == 401) {
      return AuthFailure(parsed.generalMessage, fieldErrors: parsed.fieldErrors);
    }
    return ServerFailure(parsed.generalMessage, fieldErrors: parsed.fieldErrors);
  }

  Failure _fromGenericException(Object e) {
    if (e is Exception) {
      final parsed = ApiErrorParser.fromException(e);
      return ServerFailure(parsed.generalMessage, fieldErrors: parsed.fieldErrors);
    }
    return ServerFailure('حدث خطأ غير متوقع');
  }

  Future<void> _saveSession(LoginResponseModel response) async {
    await _storage.write(AppConstants.tokenKey, response.access);
    if (response.refresh != null) {
      await _storage.write(AppConstants.refreshTokenKey, response.refresh!);
    }
    await _storage.write(AppConstants.userKey, jsonEncode(response.user.toJson()));
  }

  @override
  Future<Either<Failure, UserEntity>> login(
      String email, String password, String role) async {
    try {
      final response = await _remoteDataSource.login(email, password, role);
      final user = response.user.toEntity();
      await _saveSession(response);
      return Right(user);
    } on DioException catch (e) {
      return Left(_fromDioException(e));
    } catch (e) {
      return Left(_fromGenericException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerPatient(
      Map<String, dynamic> data) async {
    try {
      final response = await _remoteDataSource.registerPatient(data);
      final user = response.user.toEntity();
      await _saveSession(response);
      return Right(user);
    } on DioException catch (e) {
      return Left(_fromDioException(e));
    } catch (e) {
      return Left(_fromGenericException(e));
    }
  }

  @override
  Future<Either<Failure, void>> registerNurse(
    Map<String, dynamic> data, {
    XFile? photo,
    XFile? certificate,
    XFile? syndicateCard,
  }) async {
    try {
      await _remoteDataSource.registerNurse(
        data,
        photo: photo,
        certificate: certificate,
        syndicateCard: syndicateCard,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_fromDioException(e));
    } catch (e) {
      return Left(_fromGenericException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await _storage.read(AppConstants.refreshTokenKey);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _remoteDataSource.logout(refreshToken);
      }
    } catch (_) {
      // Continue even if API call fails
    }
    try {
      await _storage.delete(AppConstants.tokenKey);
      await _storage.delete(AppConstants.refreshTokenKey);
      await _storage.delete(AppConstants.userKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear session'));
    }
  }
}
