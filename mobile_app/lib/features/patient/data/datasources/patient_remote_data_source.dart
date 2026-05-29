import 'package:dio/dio.dart';
import 'package:mongez/core/constants/api_constants.dart';
import 'package:mongez/core/errors/exceptions.dart';
import 'package:mongez/core/network/api_client.dart';
import 'package:mongez/features/patient/data/models/patient_order_model.dart';

class PatientRemoteDataSource {
  final ApiClient _apiClient;

  PatientRemoteDataSource(this._apiClient);

  Future<List<PatientOrderModel>> getOrders() async {
    try {
      final response = await _apiClient.get(ApiConstants.patientOrders);
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['results'] ?? response.data['data'] ?? []);
      return data.map((json) => PatientOrderModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to load orders',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<PatientOrderModel> createOrder({
    required String areaId,
    required String address,
    required List<String> services,
    int? fullCareHours,
    String? fullCareGender,
  }) async {
    try {
      final body = <String, dynamic>{
        'area_id': areaId,
        'address': address,
        'services': services,
      };
      if (fullCareHours != null) body['full_care_hours'] = fullCareHours;
      if (fullCareGender != null) body['full_care_gender'] = fullCareGender;

      final response = await _apiClient.post(ApiConstants.patientOrders, data: body);
      return PatientOrderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to create order',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<PatientOrderModel> completeOrder(String id) async {
    try {
      final response = await _apiClient.post(ApiConstants.patientCompleteOrder(id));
      return PatientOrderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to complete order',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<PatientOrderModel> cancelOrder(String id) async {
    try {
      final response = await _apiClient.post(ApiConstants.patientCancelOrder(id));
      return PatientOrderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to cancel order',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> rateOrder(String id, {required int score, String? comment}) async {
    try {
      final body = <String, dynamic>{'score': score};
      if (comment != null) body['comment'] = comment;
      await _apiClient.post(ApiConstants.patientRateOrder(id), data: body);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to rate order',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);
      return response.data;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to load profile',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> updateAddress(String address) async {
    try {
      final response = await _apiClient.patch(ApiConstants.profile, data: {'address': address});
      return response.data;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to update address',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
