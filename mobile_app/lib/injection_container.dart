import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:mongez/core/localization/localization_cubit.dart';
import 'package:mongez/core/network/api_client.dart';
import 'package:mongez/core/storage/secure_storage.dart';

import 'package:mongez/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mongez/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mongez/features/auth/domain/repositories/auth_repository.dart';
import 'package:mongez/features/auth/domain/usecases/login_usecase.dart';
import 'package:mongez/features/auth/domain/usecases/register_patient_usecase.dart';
import 'package:mongez/features/auth/domain/usecases/register_nurse_usecase.dart';
import 'package:mongez/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:mongez/features/home/data/datasources/home_remote_data_source.dart';
import 'package:mongez/features/home/data/repositories/home_repository_impl.dart';
import 'package:mongez/features/home/domain/repositories/home_repository.dart';
import 'package:mongez/features/home/domain/usecases/get_services_usecase.dart';
import 'package:mongez/features/home/domain/usecases/get_areas_usecase.dart';
import 'package:mongez/features/home/domain/usecases/get_stats_usecase.dart';

import 'package:mongez/features/patient/data/datasources/patient_remote_data_source.dart';
import 'package:mongez/features/patient/data/repositories/patient_repository_impl.dart';
import 'package:mongez/features/patient/domain/repositories/patient_repository.dart';
import 'package:mongez/features/patient/domain/usecases/get_patient_orders_usecase.dart';
import 'package:mongez/features/patient/domain/usecases/create_order_usecase.dart';
import 'package:mongez/features/patient/domain/usecases/complete_order_usecase.dart';
import 'package:mongez/features/patient/domain/usecases/cancel_order_usecase.dart';
import 'package:mongez/features/patient/domain/usecases/rate_order_usecase.dart';
import 'package:mongez/features/patient/domain/usecases/get_patient_profile_usecase.dart';
import 'package:mongez/features/patient/domain/usecases/update_address_usecase.dart';

import 'package:mongez/features/nurse/data/datasources/nurse_remote_data_source.dart';
import 'package:mongez/features/nurse/data/repositories/nurse_repository_impl.dart';
import 'package:mongez/features/nurse/domain/repositories/nurse_repository.dart';
import 'package:mongez/features/nurse/domain/usecases/get_nurse_active_orders_usecase.dart';
import 'package:mongez/features/nurse/domain/usecases/get_nurse_my_orders_usecase.dart';
import 'package:mongez/features/nurse/domain/usecases/accept_order_usecase.dart';
import 'package:mongez/features/nurse/domain/usecases/complete_nurse_order_usecase.dart';
import 'package:mongez/features/nurse/domain/usecases/cancel_nurse_order_usecase.dart';
import 'package:mongez/features/nurse/domain/usecases/get_earnings_usecase.dart';
import 'package:mongez/features/nurse/domain/usecases/get_ratings_usecase.dart';
import 'package:mongez/features/nurse/domain/usecases/get_nurse_profile_usecase.dart';
import 'package:mongez/features/nurse/domain/usecases/get_nurse_stats_usecase.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureStorage());
  sl.registerLazySingleton(() => LocalizationCubit(storage: sl<SecureStorage>()));

  _initAuth();
  _initHome();
  _initPatient();
  _initNurse();
}

void _initAuth() {
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl<ApiClient>()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterPatientUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterNurseUseCase(sl<AuthRepository>()));

  sl.registerLazySingleton(() => AuthBloc(
    loginUseCase: sl<LoginUseCase>(),
    registerPatientUseCase: sl<RegisterPatientUseCase>(),
    registerNurseUseCase: sl<RegisterNurseUseCase>(),
  ));
}

void _initHome() {
  sl.registerLazySingleton(() => HomeRemoteDataSource(sl<ApiClient>()));

  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl<HomeRemoteDataSource>()));

  sl.registerLazySingleton(() => GetServicesUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton(() => GetAreasUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton(() => GetStatsUseCase(sl<HomeRepository>()));
}

void _initPatient() {
  sl.registerLazySingleton(() => PatientRemoteDataSource(sl<ApiClient>()));

  sl.registerLazySingleton<PatientRepository>(() => PatientRepositoryImpl(sl<PatientRemoteDataSource>()));

  sl.registerLazySingleton(() => GetPatientOrdersUseCase(sl<PatientRepository>()));
  sl.registerLazySingleton(() => CreateOrderUseCase(sl<PatientRepository>()));
  sl.registerLazySingleton(() => CompleteOrderUseCase(sl<PatientRepository>()));
  sl.registerLazySingleton(() => CancelOrderUseCase(sl<PatientRepository>()));
  sl.registerLazySingleton(() => RateOrderUseCase(sl<PatientRepository>()));
  sl.registerLazySingleton(() => GetPatientProfileUseCase(sl<PatientRepository>()));
  sl.registerLazySingleton(() => UpdateAddressUseCase(sl<PatientRepository>()));
}

void _initNurse() {
  sl.registerLazySingleton<NurseRemoteDataSource>(() => NurseRemoteDataSourceImpl(sl<ApiClient>()));

  sl.registerLazySingleton<NurseRepository>(() => NurseRepositoryImpl(sl<NurseRemoteDataSource>()));

  sl.registerLazySingleton(() => GetNurseActiveOrdersUseCase(sl<NurseRepository>()));
  sl.registerLazySingleton(() => GetNurseMyOrdersUseCase(sl<NurseRepository>()));
  sl.registerLazySingleton(() => AcceptOrderUseCase(sl<NurseRepository>()));
  sl.registerLazySingleton(() => CompleteNurseOrderUseCase(sl<NurseRepository>()));
  sl.registerLazySingleton(() => CancelNurseOrderUseCase(sl<NurseRepository>()));
  sl.registerLazySingleton(() => GetEarningsUseCase(sl<NurseRepository>()));
  sl.registerLazySingleton(() => GetRatingsUseCase(sl<NurseRepository>()));
  sl.registerLazySingleton(() => GetNurseProfileUseCase(sl<NurseRepository>()));
  sl.registerLazySingleton(() => GetNurseStatsUseCase(sl<NurseRepository>()));
}
