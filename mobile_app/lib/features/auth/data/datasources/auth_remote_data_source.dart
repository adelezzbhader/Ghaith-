import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongez/core/constants/api_constants.dart';
import 'package:mongez/core/network/api_client.dart';
import '../models/login_response_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<LoginResponseModel> login(
      String email, String password, String role) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
        'role': role,
      },
    );
    final raw = response.data as Map<String, dynamic>;
    return LoginResponseModel.fromJson(raw['data'] as Map<String, dynamic>? ?? raw);
  }

  Future<LoginResponseModel> registerPatient(
      Map<String, dynamic> data) async {
    final payload = _toSnakeCase(data);
    if (payload['gender'] != null) {
      payload['gender'] = (payload['gender'] as String).toUpperCase();
    }
    payload['accepted_terms'] = true;
    final response = await _apiClient.post(
      ApiConstants.registerPatient,
      data: payload,
    );
    final raw = response.data as Map<String, dynamic>;
    return LoginResponseModel.fromJson(raw['data'] as Map<String, dynamic>? ?? raw);
  }

  Future<void> logout(String refreshToken) async {
    await _apiClient.post(
      ApiConstants.logout,
      data: {'refresh': refreshToken},
    );
  }

  Future<void> registerNurse(
    Map<String, dynamic> data, {
    XFile? photo,
    XFile? certificate,
    XFile? syndicateCard,
  }) async {
    final snakeData = _toSnakeCase(data);
    if (snakeData['gender'] != null) {
      snakeData['gender'] = (snakeData['gender'] as String).toUpperCase();
    }
    if (snakeData['interview_date'] != null) {
      snakeData['interview_date'] =
          (snakeData['interview_date'] as String).split('T').first;
    }
    final formData = FormData.fromMap(snakeData);
    if (photo != null) {
      formData.files.add(MapEntry(
        'profile_image',
        MultipartFile.fromBytes(await photo.readAsBytes(),
            filename: photo.name),
      ));
    }
    if (certificate != null) {
      formData.files.add(MapEntry(
        'graduation_certificate',
        MultipartFile.fromBytes(await certificate.readAsBytes(),
            filename: certificate.name),
      ));
    }
    if (syndicateCard != null) {
      formData.files.add(MapEntry(
        'syndicate_card',
        MultipartFile.fromBytes(await syndicateCard.readAsBytes(),
            filename: syndicateCard.name),
      ));
    }
    await _apiClient.post(
      ApiConstants.registerNurse,
      data: formData,
    );
  }

  Map<String, dynamic> _toSnakeCase(Map<String, dynamic> camelCaseMap) {
    final result = <String, dynamic>{};
    for (final entry in camelCaseMap.entries) {
      final snakeKey = _camelToSnake(entry.key);
      result[snakeKey] = entry.value;
    }
    return result;
  }

  String _camelToSnake(String key) {
    return key.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }
}
