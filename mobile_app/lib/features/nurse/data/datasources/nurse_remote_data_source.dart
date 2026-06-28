import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_error_parser.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/nurse_order_model.dart';
import '../models/earnings_model.dart';
import '../models/rating_model.dart';

abstract class NurseRemoteDataSource {
  Future<Map<String, dynamic>> getProfile();
  Future<List<NurseOrderModel>> getActiveOrders();
  Future<List<NurseOrderModel>> getMyOrders();
  Future<NurseOrderModel> acceptOrder(String id);
  Future<NurseOrderModel> completeOrder(String id);
  Future<void> cancelOrder(String id);
  Future<EarningsModel> getEarnings();
  Future<List<RatingModel>> getRatings();
  Future<Map<String, dynamic>> getStats();
  Future<List<Map<String, dynamic>>> getServices();
}

class NurseRemoteDataSourceImpl implements NurseRemoteDataSource {
  final ApiClient _apiClient;

  NurseRemoteDataSourceImpl(this._apiClient);

  @override
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

  @override
  Future<List<NurseOrderModel>> getActiveOrders() async {
    try {
      final response = await _apiClient.get(ApiConstants.nurseActiveOrders);
      final data = response.data;
      List<dynamic> ordersList;
      if (data is List) {
        ordersList = data;
      } else if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic> && inner['results'] is List) {
          ordersList = inner['results'] as List;
        } else if (inner is List) {
          ordersList = inner;
        } else if (data['results'] is List) {
          ordersList = data['results'] as List;
        } else if (data['orders'] is List) {
          ordersList = data['orders'] as List;
        } else if (data['data'] is List) {
          ordersList = data['data'] as List;
        } else {
          ordersList = [];
        }
      } else {
        ordersList = [];
      }
      return ordersList
          .where((e) => e is Map<String, dynamic>)
          .map((e) => NurseOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  @override
  Future<List<NurseOrderModel>> getMyOrders() async {
    try {
      final response = await _apiClient.get(ApiConstants.nurseOrders);
      final data = response.data;
      List<dynamic> ordersList;
      if (data is List) {
        ordersList = data;
      } else if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic> && inner['results'] is List) {
          ordersList = inner['results'] as List;
        } else if (inner is List) {
          ordersList = inner;
        } else if (data['results'] is List) {
          ordersList = data['results'] as List;
        } else if (data['orders'] is List) {
          ordersList = data['orders'] as List;
        } else if (data['data'] is List) {
          ordersList = data['data'] as List;
        } else {
          ordersList = [];
        }
      } else {
        ordersList = [];
      }
      return ordersList
          .where((e) => e is Map<String, dynamic>)
          .map((e) => NurseOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  @override
  Future<NurseOrderModel> acceptOrder(String id) async {
    try {
      final response = await _apiClient.post(ApiConstants.nurseAcceptOrder(id));
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      if (data['order'] is Map<String, dynamic>) {
        return NurseOrderModel.fromJson(data['order'] as Map<String, dynamic>);
      }
      return NurseOrderModel.fromJson(data);
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  @override
  Future<NurseOrderModel> completeOrder(String id) async {
    try {
      final response = await _apiClient.post(ApiConstants.nurseCompleteOrder(id));
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      if (data['order'] is Map<String, dynamic>) {
        return NurseOrderModel.fromJson(data['order'] as Map<String, dynamic>);
      }
      return NurseOrderModel.fromJson(data);
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  @override
  Future<void> cancelOrder(String id) async {
    try {
      await _apiClient.post(ApiConstants.nurseCancelOrder(id));
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  @override
  Future<EarningsModel> getEarnings() async {
    try {
      final response = await _apiClient.get(ApiConstants.nurseEarnings);
      final raw = response.data as Map<String, dynamic>;
      final data = raw['data'] as Map<String, dynamic>? ?? raw;
      return EarningsModel.fromJson(data);
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  @override
  Future<List<RatingModel>> getRatings() async {
    try {
      final response = await _apiClient.get(ApiConstants.nurseRatings);
      final data = response.data;
      List<dynamic> ratingsList;
      if (data is List) {
        ratingsList = data;
      } else if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic> && inner['results'] is List) {
          ratingsList = inner['results'] as List;
        } else if (inner is List) {
          ratingsList = inner;
        } else if (data['results'] is List) {
          ratingsList = data['results'] as List;
        } else if (data['ratings'] is List) {
          ratingsList = data['ratings'] as List;
        } else if (data['data'] is List) {
          ratingsList = data['data'] as List;
        } else {
          ratingsList = [];
        }
      } else {
        ratingsList = [];
      }
      return ratingsList
          .where((e) => e is Map<String, dynamic>)
          .map((e) => RatingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.nurseStats);
      final raw = response.data as Map<String, dynamic>;
      return raw['data'] as Map<String, dynamic>? ?? raw;
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getServices() async {
    try {
      final response = await _apiClient.get(ApiConstants.services);
      final data = response.data;
      List<dynamic> servicesList;
      if (data is List) {
        servicesList = data;
      } else if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic> && inner['results'] is List) {
          servicesList = inner['results'] as List;
        } else if (inner is List) {
          servicesList = inner;
        } else if (data['results'] is List) {
          servicesList = data['results'] as List;
        } else if (data['data'] is List) {
          servicesList = data['data'] as List;
        } else {
          servicesList = [];
        }
      } else {
        servicesList = [];
      }
      return servicesList.where((e) => e is Map<String, dynamic>).map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      final parsed = ApiErrorParser.fromDioError(e);
      throw ServerException(message: parsed.generalMessage, statusCode: parsed.statusCode, fieldErrors: parsed.fieldErrors);
    }
  }
}
