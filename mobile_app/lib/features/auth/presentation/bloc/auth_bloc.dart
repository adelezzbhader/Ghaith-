import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/core/constants/app_constants.dart';
import 'package:mongez/core/storage/secure_storage.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_nurse_usecase.dart';
import '../../domain/usecases/register_patient_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterPatientUseCase _registerPatientUseCase;
  final RegisterNurseUseCase _registerNurseUseCase;
  final AuthRepository _authRepository;
  final SecureStorage _storage;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterPatientUseCase registerPatientUseCase,
    required RegisterNurseUseCase registerNurseUseCase,
    required AuthRepository authRepository,
    SecureStorage? storage,
  })  : _loginUseCase = loginUseCase,
        _registerPatientUseCase = registerPatientUseCase,
        _registerNurseUseCase = registerNurseUseCase,
        _authRepository = authRepository,
        _storage = storage ?? SecureStorage(),
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
      (failure) async => emit(AuthError(
        message: failure.message,
        fieldErrors: failure.fieldErrors,
      )),
      (user) async {
        final token = await _storage.read(AppConstants.tokenKey) ?? '';
        emit(AuthAuthenticated(user: user, token: token));
      },
    );
  }

  Future<void> _onRegisterPatient(
      RegisterPatientEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _registerPatientUseCase(event.data);
    await result.fold(
      (failure) async => emit(AuthError(
        message: failure.message,
        fieldErrors: failure.fieldErrors,
      )),
      (user) async {
        final token = await _storage.read(AppConstants.tokenKey) ?? '';
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
      (failure) async => emit(AuthError(
        message: failure.message,
        fieldErrors: failure.fieldErrors,
      )),
      (_) async => emit(const AuthSuccess(
          message:
              'تم إرسال طلب التسجيل بنجاح! سيتم مراجعة طلبك من قبل الإدارة والتواصل معك لتحديد موعد المقابلة الشخصية.')),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(AuthInitial());
  }

  Future<void> _onCheckAuth(
      CheckAuthEvent event, Emitter<AuthState> emit) async {
    final token = await _storage.read(AppConstants.tokenKey);
    final userData = await _storage.read(AppConstants.userKey);
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

}
