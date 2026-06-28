import 'package:dio/dio.dart';
import 'package:mongez/core/constants/api_constants.dart';
import 'package:mongez/core/errors/api_error_parser.dart';
import 'package:mongez/core/errors/exceptions.dart';
import 'package:mongez/core/network/api_client.dart';
import 'package:mongez/features/patient/data/models/patient_order_model.dart';

class PatientRemoteDataSource {
  final ApiClient _apiClient;

  PatientRemoteDataSource(this._apiClient);

  Future<List<PatientOrderModel>> getOrders() async {
    try {
      final response = await _apiClient.get(ApiConstants.patientOrders);
      final raw = response.data;
      List<dynamic> ordersList;
      if (raw is List) {
        ordersList = raw;
      } else if (raw is Map<String, dynamic>) {
        final inner = raw['data'];
        if (inner is Map<String, dynamic> && inner['results'] is List) {
          ordersList = inner['results'] as List;
        } else if (raw['results'] is List) {
          ordersList = raw['results'] as List;
        } else if (raw['orders'] is List) {
          ordersList = raw['orders'] as List;
        } else if (raw['data'] is List) {
          ordersList = raw['data'] as List;
        } else {
          ordersList = [];
        }
      } else {
        ordersList = [];
      }
      return ordersList.map((json) => PatientOrderModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
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
        'services': services.map((id) => {'service_id': id, 'quantity': 1}).toList(),
      };
      if (fullCareHours != null) body['full_care_hours'] = fullCareHours;
      if (fullCareGender != null) body['full_care_gender'] = fullCareGender;

      final response = await _apiClient.post(ApiConstants.patientOrders, data: body);
      final raw = response.data as Map<String, dynamic>;
      return PatientOrderModel.fromJson(raw['data'] as Map<String, dynamic>? ?? raw);
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  Future<PatientOrderModel> completeOrder(String id) async {
    try {
      final response = await _apiClient.post(ApiConstants.patientCompleteOrder(id));
      final raw = response.data as Map<String, dynamic>;
      return PatientOrderModel.fromJson(raw['data'] as Map<String, dynamic>? ?? raw);
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  Future<PatientOrderModel> cancelOrder(String id) async {
    try {
      final response = await _apiClient.post(ApiConstants.patientCancelOrder(id));
      final raw = response.data as Map<String, dynamic>;
      return PatientOrderModel.fromJson(raw['data'] as Map<String, dynamic>? ?? raw);
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  Future<void> rateOrder(String id, {required int score, String? comment}) async {
    try {
      final body = <String, dynamic>{'score': score};
      if (comment != null) body['comment'] = comment;
      await _apiClient.post(ApiConstants.patientRateOrder(id), data: body);
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);
      final raw = response.data as Map<String, dynamic>;
      return raw['data'] as Map<String, dynamic>? ?? raw;
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  Future<Map<String, dynamic>> updateAddress(String address) async {
    try {
      final response = await _apiClient.patch(ApiConstants.profile, data: {'address': address});
      final raw = response.data as Map<String, dynamic>;
      return raw['data'] as Map<String, dynamic>? ?? raw;
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }
}
