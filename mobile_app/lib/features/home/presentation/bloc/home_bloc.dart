import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/home/domain/entities/area_entity.dart';
import 'package:mongez/features/home/domain/entities/service_entity.dart';
import 'package:mongez/features/home/domain/entities/stats_entity.dart';
import 'package:mongez/features/home/domain/usecases/get_areas_usecase.dart';
import 'package:mongez/features/home/domain/usecases/get_services_usecase.dart';
import 'package:mongez/features/home/domain/usecases/get_stats_usecase.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomePageLoaded extends HomeEvent {
  const HomePageLoaded();
}

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<ServiceEntity> services;
  final List<AreaEntity> areas;
  final StatsEntity stats;

  const HomeLoaded({
    required this.services,
    required this.areas,
    required this.stats,
  });

  @override
  List<Object?> get props => [services, areas, stats];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetServicesUseCase getServicesUseCase;
  final GetAreasUseCase getAreasUseCase;
  final GetStatsUseCase getStatsUseCase;

  HomeBloc({
    required this.getServicesUseCase,
    required this.getAreasUseCase,
    required this.getStatsUseCase,
  }) : super(const HomeInitial()) {
    on<HomePageLoaded>(_onHomePageLoaded);
  }

  Future<void> _onHomePageLoaded(HomePageLoaded event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    final results = await Future.wait([
      getServicesUseCase.call(),
      getAreasUseCase.call(),
      getStatsUseCase.call(),
    ]);

    final servicesResult = results[0] as Either<Failure, List<ServiceEntity>>;
    final areasResult = results[1] as Either<Failure, List<AreaEntity>>;
    final statsResult = results[2] as Either<Failure, StatsEntity>;

    final services = servicesResult.fold((l) => <ServiceEntity>[], (r) => r);
    final areas = areasResult.fold((l) => <AreaEntity>[], (r) => r);
    final stats = statsResult.fold(
      (l) => const StatsEntity(dailyRequests: 0, clientTrust: 0, activeNurses: 0),
      (r) => r,
    );

    emit(HomeLoaded(services: services, areas: areas, stats: stats));
  }
}
