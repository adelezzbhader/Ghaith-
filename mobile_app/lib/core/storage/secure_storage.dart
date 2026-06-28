import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  final FlutterSecureStorage? _native;

  SecureStorage() : _native = kIsWeb ? null : const FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _native!.write(key: key, value: value);
    }
  }

  Future<String?> read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return await _native!.read(key: key);
  }

  Future<void> delete(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _native!.delete(key: key);
    }
  }

  Future<String?> getToken() async {
    return await read('token');
  }

  Future<void> deleteToken() async {
    await delete('token');
  }

  Future<void> saveUser(String userData) async {
    await write('user', userData);
  }

  Future<String?> getUser() async {
    return await read('user');
  }

  Future<void> deleteUser() async {
    await delete('user');
  }

  Future<void> saveLang(String lang) async {
    await write('lang', lang);
  }

  Future<String?> getLang() async {
    return await read('lang');
  }
}
