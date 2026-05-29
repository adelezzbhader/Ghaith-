import 'package:dio/dio.dart';
import 'package:mongez/core/constants/api_constants.dart';
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
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['results'] ?? response.data['data'] ?? []);
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to load services',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<AreaModel>> getAreas() async {
    try {
      final response = await _apiClient.get(ApiConstants.areas);
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['results'] ?? response.data['data'] ?? []);
      return data.map((json) => AreaModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to load areas',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<StatsModel> getStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.siteStats);
      return StatsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to load stats',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
