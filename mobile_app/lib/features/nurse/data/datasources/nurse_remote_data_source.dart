import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
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
}

class NurseRemoteDataSourceImpl implements NurseRemoteDataSource {
  final ApiClient _apiClient;

  NurseRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'فشل في تحميل الملف الشخصي',
        statusCode: e.response?.statusCode,
      );
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
      } else if (data is Map<String, dynamic> && data['results'] is List) {
        ordersList = data['results'] as List;
      } else if (data is Map<String, dynamic> && data['orders'] is List) {
        ordersList = data['orders'] as List;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        ordersList = data['data'] as List;
      } else {
        ordersList = [];
      }
      return ordersList
          .where((e) => e is Map<String, dynamic>)
          .map((e) => NurseOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'فشل في تحميل الطلبات النشطة',
        statusCode: e.response?.statusCode,
      );
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
      } else if (data is Map<String, dynamic> && data['results'] is List) {
        ordersList = data['results'] as List;
      } else if (data is Map<String, dynamic> && data['orders'] is List) {
        ordersList = data['orders'] as List;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        ordersList = data['data'] as List;
      } else {
        ordersList = [];
      }
      return ordersList
          .where((e) => e is Map<String, dynamic>)
          .map((e) => NurseOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'فشل في تحميل طلباتي',
        statusCode: e.response?.statusCode,
      );
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
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'فشل في قبول الطلب',
        statusCode: e.response?.statusCode,
      );
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
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'فشل في إتمام الطلب',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> cancelOrder(String id) async {
    try {
      await _apiClient.post(ApiConstants.nurseCancelOrder(id));
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'فشل في إلغاء الطلب',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EarningsModel> getEarnings() async {
    try {
      final response = await _apiClient.get(ApiConstants.nurseEarnings);
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      return EarningsModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'فشل في تحميل الأرباح',
        statusCode: e.response?.statusCode,
      );
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
      } else if (data is Map<String, dynamic> && data['results'] is List) {
        ratingsList = data['results'] as List;
      } else if (data is Map<String, dynamic> && data['ratings'] is List) {
        ratingsList = data['ratings'] as List;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        ratingsList = data['data'] as List;
      } else {
        ratingsList = [];
      }
      return ratingsList
          .where((e) => e is Map<String, dynamic>)
          .map((e) => RatingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'فشل في تحميل التقييمات',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.nurseStats);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'فشل في تحميل الإحصائيات',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
