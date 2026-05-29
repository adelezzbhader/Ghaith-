import 'dart:io';

import 'package:dio/dio.dart';
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
    return LoginResponseModel.fromJson(response.data);
  }

  Future<LoginResponseModel> registerPatient(
      Map<String, dynamic> data) async {
    final payload = _toSnakeCase(data);
    payload['accepted_terms'] = true;
    final response = await _apiClient.post(
      ApiConstants.registerPatient,
      data: payload,
    );
    return LoginResponseModel.fromJson(response.data);
  }

  Future<void> registerNurse(
    Map<String, dynamic> data, {
    File? photo,
    File? certificate,
    File? syndicateCard,
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
        await MultipartFile.fromFile(photo.path,
            filename: photo.path.split('\\').last),
      ));
    }
    if (certificate != null) {
      formData.files.add(MapEntry(
        'graduation_certificate',
        await MultipartFile.fromFile(certificate.path,
            filename: certificate.path.split('\\').last),
      ));
    }
    if (syndicateCard != null) {
      formData.files.add(MapEntry(
        'syndicate_card',
        await MultipartFile.fromFile(syndicateCard.path,
            filename: syndicateCard.path.split('\\').last),
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
