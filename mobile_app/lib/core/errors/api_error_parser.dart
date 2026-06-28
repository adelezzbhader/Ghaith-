import 'dart:io';

import 'package:dio/dio.dart';

class ApiErrorParser {
  Map<String, List<String>> fieldErrors = {};
  String generalMessage = '';
  int? statusCode;

  ApiErrorParser._();

  factory ApiErrorParser.fromDioError(DioException e) {
    final parser = ApiErrorParser._();
    parser.statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        parser.generalMessage = 'تعذر الاتصال بالخادم، تحقق من اتصالك بالإنترنت';
        return parser;
      case DioExceptionType.connectionError:
        if (e.error is SocketException) {
          parser.generalMessage = 'لا يوجد اتصال بالإنترنت';
        } else {
          parser.generalMessage = 'تعذر الاتصال بالخادم';
        }
        return parser;
      case DioExceptionType.badCertificate:
        parser.generalMessage = 'مشكلة في شهادة الأمان';
        return parser;
      case DioExceptionType.cancel:
        parser.generalMessage = 'تم إلغاء الطلب';
        return parser;
      case DioExceptionType.badResponse:
        parser._parseErrorData(e.response?.data);
        return parser;
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          parser.generalMessage = 'لا يوجد اتصال بالإنترنت';
        } else {
          parser.generalMessage = e.message ?? 'حدث خطأ غير متوقع';
        }
        return parser;
    }
  }

  factory ApiErrorParser.fromException(Exception e) {
    final parser = ApiErrorParser._();
    if (e is DioException) {
      return ApiErrorParser.fromDioError(e);
    } else if (e is SocketException) {
      parser.generalMessage = 'لا يوجد اتصال بالإنترنت';
    } else if (e is HttpException) {
      parser.generalMessage = 'تعذر الاتصال بالخادم';
    } else if (e is FormatException) {
      parser.generalMessage = 'خطأ في استجابة الخادم';
    } else {
      parser.generalMessage = 'حدث خطأ غير متوقع';
    }
    return parser;
  }

  void _parseErrorData(dynamic data) {
    if (data is! Map) return;

    for (final entry in data.entries) {
      final key = entry.key.toString();
      final value = entry.value;

      if (key == 'success') continue;

      if (key == 'detail' || key == 'error') {
        generalMessage = value.toString();
      } else if (key == 'message') {
        final msg = value.toString().toLowerCase();
        if (msg != 'validation error.') {
          generalMessage = value.toString();
        }
      } else if (key == 'non_field_errors' && value is List) {
        generalMessage = value.map((e) => e.toString()).join('\n');
      } else if (key == 'field_errors' && value is Map) {
        for (final inner in value.entries) {
          final innerVal = inner.value;
          if (innerVal is List) {
            fieldErrors[inner.key.toString()] =
                innerVal.map((e) => e.toString()).toList();
          } else if (innerVal is String) {
            fieldErrors[inner.key.toString()] = [innerVal];
          }
        }
      } else if (key == 'field_errors' && value is List) {
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            final field = item['field']?.toString() ?? '';
            final msg = item['message']?.toString() ?? '';
            if (field.isNotEmpty) {
              fieldErrors.putIfAbsent(field, () => []);
              fieldErrors[field]!.add(msg);
            }
          }
        }
      } else if (value is List) {
        fieldErrors[key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        fieldErrors[key] = [value];
      } else if (value is Map && statusCode != null && statusCode! >= 400) {
        for (final inner in value.entries) {
          final innerVal = inner.value;
          if (innerVal is List) {
            fieldErrors[inner.key.toString()] =
                innerVal.map((e) => e.toString()).toList();
          } else if (innerVal is String) {
            fieldErrors[inner.key.toString()] = [innerVal];
          }
        }
      }
    }

    if (generalMessage.isEmpty && fieldErrors.isNotEmpty) {
      generalMessage = fieldErrors.values.first.first;
    }
    if (generalMessage.isEmpty) {
      generalMessage = _defaultMessage(statusCode);
    }
  }

  String fieldError(String field) {
    final errors = fieldErrors[field];
    if (errors != null && errors.isNotEmpty) return errors.first;
    return '';
  }

  bool hasFieldError(String field) => fieldErrors.containsKey(field);

  factory ApiErrorParser({String message = 'حدث خطأ غير متوقع'}) {
    return ApiErrorParser._()..generalMessage = message;
  }

  static String _defaultMessage(int? code) {
    switch (code) {
      case 400:
        return 'بيانات غير صحيحة';
      case 401:
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 403:
        return 'ليس لديك صلاحية للوصول';
      case 404:
        return 'الصفحة المطلوبة غير موجودة';
      case 409:
        return 'البيانات موجودة مسبقاً';
      case 422:
        return 'بيانات غير صالحة';
      case 429:
        return 'طلبات كثيرة جداً، حاول لاحقاً';
      case 500:
        return 'خطأ في الخادم، حاول لاحقاً';
      case 502:
        return 'الخادم غير متاح مؤقتاً';
      case 503:
        return 'الخدمة غير متاحة مؤقتاً';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
