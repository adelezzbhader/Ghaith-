import 'package:dio/dio.dart';
import 'package:mongez/core/constants/api_constants.dart';
import 'package:mongez/core/errors/api_error_parser.dart';
import 'package:mongez/core/errors/exceptions.dart';
import 'package:mongez/core/network/api_client.dart';
import 'package:mongez/features/home/data/models/area_model.dart';
import 'package:mongez/features/home/data/models/service_model.dart';
import 'package:mongez/features/home/data/models/stats_model.dart';

class HomeRemoteDataSource {
  final ApiClient _apiClient;

  HomeRemoteDataSource(this._apiClient);

  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await _apiClient.get(ApiConstants.services);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((json) => ServiceModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  Future<List<AreaModel>> getAreas() async {
    try {
      final response = await _apiClient.get(ApiConstants.areas);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((json) => AreaModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  Future<StatsModel> getStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.siteStats);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return StatsModel.fromJson(data);
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }
}
