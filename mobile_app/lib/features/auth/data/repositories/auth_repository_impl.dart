import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mongez/core/constants/app_constants.dart';
import 'package:mongez/core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl(this._remoteDataSource, this._storage);

  @override
  Future<Either<Failure, UserEntity>> login(
      String email, String password, String role) async {
    try {
      final response = await _remoteDataSource.login(email, password, role);
      final user = response.user.toEntity();
      await _storage.write(key: AppConstants.tokenKey, value: response.access);
      await _storage.write(
          key: AppConstants.userKey, value: jsonEncode(response.user.toJson()));
      return Right(user);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      if (e.response?.statusCode == 401) {
        return Left(AuthFailure(message));
      }
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerPatient(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _remoteDataSource.registerPatient(data);
      final user = response.user.toEntity();
      await _storage.write(key: AppConstants.tokenKey, value: response.access);
      await _storage.write(
          key: AppConstants.userKey, value: jsonEncode(response.user.toJson()));
      return Right(user);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerNurse(
    Map<String, dynamic> data, {
    File? photo,
    File? certificate,
    File? syndicateCard,
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
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
      await _storage.delete(key: AppConstants.userKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear session'));
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      for (final key in data.keys) {
        final value = data[key];
        if (value is List && value.isNotEmpty) {
          return value[0].toString();
        }
        if (value is String) {
          return value;
        }
      }
    }
    return e.message ?? 'Something went wrong';
  }
}
