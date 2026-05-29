import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/secure_storage.dart';

class LocalizationCubit extends Cubit<Locale> {
  final SecureStorage _storage;

  LocalizationCubit({SecureStorage? storage})
      : _storage = storage ?? SecureStorage(),
        super(const Locale('ar'));

  Future<void> loadLocale() async {
    final lang = await _storage.getLang();
    if (lang == 'en') {
      emit(const Locale('en'));
    } else {
      emit(const Locale('ar'));
    }
  }

  Future<void> changeLocale(Locale locale) async {
    await _storage.saveLang(locale.languageCode);
    emit(locale);
  }

  Future<void> toggleLanguage() async {
    if (state.languageCode == 'ar') {
      await changeLocale(const Locale('en'));
    } else {
      await changeLocale(const Locale('ar'));
    }
  }
}
