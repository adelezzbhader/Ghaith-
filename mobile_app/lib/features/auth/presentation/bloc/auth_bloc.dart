import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mongez/core/constants/app_constants.dart';
import 'package:mongez/core/errors/failures.dart';
import '../../data/models/user_model.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_nurse_usecase.dart';
import '../../domain/usecases/register_patient_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterPatientUseCase _registerPatientUseCase;
  final RegisterNurseUseCase _registerNurseUseCase;
  final FlutterSecureStorage _storage;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterPatientUseCase registerPatientUseCase,
    required RegisterNurseUseCase registerNurseUseCase,
    FlutterSecureStorage? storage,
  })  : _loginUseCase = loginUseCase,
        _registerPatientUseCase = registerPatientUseCase,
        _registerNurseUseCase = registerNurseUseCase,
        _storage = storage ?? const FlutterSecureStorage(),
        super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterPatientEvent>(_onRegisterPatient);
    on<RegisterNurseEvent>(_onRegisterNurse);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _loginUseCase(event.email, event.password, event.role);
    await result.fold(
      (failure) async => emit(AuthError(message: _mapFailure(failure))),
      (user) async {
        final token = await _storage.read(key: AppConstants.tokenKey) ?? '';
        emit(AuthAuthenticated(user: user, token: token));
      },
    );
  }

  Future<void> _onRegisterPatient(
      RegisterPatientEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _registerPatientUseCase(event.data);
    await result.fold(
      (failure) async => emit(AuthError(message: _mapFailure(failure))),
      (user) async {
        final token = await _storage.read(key: AppConstants.tokenKey) ?? '';
        emit(AuthAuthenticated(user: user, token: token));
      },
    );
  }

  Future<void> _onRegisterNurse(
      RegisterNurseEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _registerNurseUseCase(
      event.data,
      photo: event.photo,
      certificate: event.certificate,
      syndicateCard: event.syndicateCard,
    );
    await result.fold(
      (failure) async => emit(AuthError(message: _mapFailure(failure))),
      (_) async => emit(const AuthSuccess(
          message:
              'تم إرسال طلب التسجيل بنجاح! سيتم مراجعة طلبك من قبل الإدارة والتواصل معك لتحديد موعد المقابلة الشخصية.')),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
    emit(AuthInitial());
  }

  Future<void> _onCheckAuth(
      CheckAuthEvent event, Emitter<AuthState> emit) async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    final userData = await _storage.read(key: AppConstants.userKey);
    if (token != null && userData != null && token.isNotEmpty) {
      try {
        final Map<String, dynamic> userMap =
            jsonDecode(userData) as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap).toEntity();
        emit(AuthAuthenticated(user: user, token: token));
      } catch (_) {
        emit(AuthInitial());
      }
    } else {
      emit(AuthInitial());
    }
  }

  String _mapFailure(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is AuthFailure) return failure.message;
    if (failure is NetworkFailure) return 'لا يوجد اتصال بالإنترنت';
    if (failure is CacheFailure) return 'خطأ في حفظ البيانات';
    return 'حدث خطأ غير متوقع';
  }
}
