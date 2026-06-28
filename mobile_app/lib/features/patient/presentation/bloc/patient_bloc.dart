import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/core/errors/api_error_parser.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/patient/domain/entities/order_entity.dart';
import 'package:mongez/features/patient/domain/repositories/patient_repository.dart';
import 'package:mongez/features/patient/domain/usecases/cancel_order_usecase.dart';
import 'package:mongez/features/patient/domain/usecases/complete_order_usecase.dart';
import 'package:mongez/features/patient/domain/usecases/create_order_usecase.dart';
import 'package:mongez/features/patient/domain/usecases/get_patient_orders_usecase.dart';
import 'package:mongez/features/patient/domain/usecases/get_patient_profile_usecase.dart';
import 'package:mongez/features/patient/domain/usecases/rate_order_usecase.dart';
import 'package:mongez/features/patient/domain/usecases/update_address_usecase.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();
  @override
  List<Object?> get props => [];
}

class LoadPatientDashboard extends PatientEvent {
  const LoadPatientDashboard();
}

class CreateOrder extends PatientEvent {
  final List<String> services;
  final String areaId;
  final String address;
  final int? fullCareHours;
  final String? fullCareGender;

  const CreateOrder({
    required this.services,
    required this.areaId,
    required this.address,
    this.fullCareHours,
    this.fullCareGender,
  });

  @override
  List<Object?> get props => [services, areaId, address, fullCareHours, fullCareGender];
}

class CompleteOrder extends PatientEvent {
  final String id;
  const CompleteOrder({required this.id});
  @override
  List<Object?> get props => [id];
}

class CancelOrder extends PatientEvent {
  final String id;
  const CancelOrder({required this.id});
  @override
  List<Object?> get props => [id];
}

class RateOrder extends PatientEvent {
  final String id;
  final int score;
  final String? comment;
  const RateOrder({required this.id, required this.score, this.comment});
  @override
  List<Object?> get props => [id, score, comment];
}

class UpdateAddress extends PatientEvent {
  final String address;
  const UpdateAddress({required this.address});
  @override
  List<Object?> get props => [address];
}

class RefreshOrders extends PatientEvent {
  const RefreshOrders();
}

abstract class PatientState extends Equatable {
  const PatientState();
  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {
  const PatientInitial();
}

class PatientLoading extends PatientState {
  const PatientLoading();
}

class PatientDashboardLoaded extends PatientState {
  final List<OrderEntity> orders;
  final PatientProfile profile;

  const PatientDashboardLoaded({required this.orders, required this.profile});

  @override
  List<Object?> get props => [orders, profile];
}

class OrderCreated extends PatientState {
  final OrderEntity order;
  const OrderCreated({required this.order});
  @override
  List<Object?> get props => [order];
}

class OrderActionSuccess extends PatientState {
  final String message;
  const OrderActionSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class PatientError extends PatientState {
  final String message;
  const PatientError({required this.message});
  @override
  List<Object?> get props => [message];
}

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final GetPatientOrdersUseCase getPatientOrdersUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final CompleteOrderUseCase completeOrderUseCase;
  final CancelOrderUseCase cancelOrderUseCase;
  final RateOrderUseCase rateOrderUseCase;
  final GetPatientProfileUseCase getPatientProfileUseCase;
  final UpdateAddressUseCase updateAddressUseCase;

  PatientBloc({
    required this.getPatientOrdersUseCase,
    required this.createOrderUseCase,
    required this.completeOrderUseCase,
    required this.cancelOrderUseCase,
    required this.rateOrderUseCase,
    required this.getPatientProfileUseCase,
    required this.updateAddressUseCase,
  }) : super(const PatientInitial()) {
    on<LoadPatientDashboard>(_onLoadDashboard);
    on<CreateOrder>(_onCreateOrder);
    on<CompleteOrder>(_onCompleteOrder);
    on<CancelOrder>(_onCancelOrder);
    on<RateOrder>(_onRateOrder);
    on<UpdateAddress>(_onUpdateAddress);
    on<RefreshOrders>(_onRefreshOrders);
  }

  Future<void> _onLoadDashboard(LoadPatientDashboard event, Emitter<PatientState> emit) async {
    emit(const PatientLoading());
    try {
      final results = await Future.wait([
        getPatientOrdersUseCase.call(),
        getPatientProfileUseCase.call(),
      ]);

      final ordersResult = results[0] as Either<Failure, List<OrderEntity>>;
      final profileResult = results[1] as Either<Failure, PatientProfile>;

      final orders = ordersResult.fold((l) => <OrderEntity>[], (r) => r);
      final profile = profileResult.fold(
        (l) => PatientProfile(name: '', phone: '', email: ''),
        (r) => r,
      );

      emit(PatientDashboardLoaded(orders: orders, profile: profile));
    } catch (e) {
      final parsed = e is Exception
          ? ApiErrorParser.fromException(e)
          : ApiErrorParser();
      emit(PatientError(message: parsed.generalMessage));
    }
  }

  Future<void> _onCreateOrder(CreateOrder event, Emitter<PatientState> emit) async {
    final result = await createOrderUseCase.call(
      areaId: event.areaId,
      address: event.address,
      services: event.services,
      fullCareHours: event.fullCareHours,
      fullCareGender: event.fullCareGender,
    );
    result.fold(
      (failure) => emit(PatientError(message: failure.message)),
      (order) => emit(OrderCreated(order: order)),
    );
  }

  Future<void> _onCompleteOrder(CompleteOrder event, Emitter<PatientState> emit) async {
    final result = await completeOrderUseCase.call(event.id);
    result.fold(
      (failure) => emit(PatientError(message: failure.message)),
      (_) => emit(const OrderActionSuccess(message: 'تم تأكيد اكتمال الطلب')),
    );
  }

  Future<void> _onCancelOrder(CancelOrder event, Emitter<PatientState> emit) async {
    final result = await cancelOrderUseCase.call(event.id);
    result.fold(
      (failure) => emit(PatientError(message: failure.message)),
      (_) => emit(const OrderActionSuccess(message: 'تم إلغاء الطلب')),
    );
  }

  Future<void> _onRateOrder(RateOrder event, Emitter<PatientState> emit) async {
    final result = await rateOrderUseCase.call(event.id, score: event.score, comment: event.comment);
    result.fold(
      (failure) => emit(PatientError(message: failure.message)),
      (_) => emit(const OrderActionSuccess(message: 'تم إضافة التقييم')),
    );
  }

  Future<void> _onUpdateAddress(UpdateAddress event, Emitter<PatientState> emit) async {
    final result = await updateAddressUseCase.call(event.address);
    result.fold(
      (failure) => emit(PatientError(message: failure.message)),
      (profile) {
        if (state is PatientDashboardLoaded) {
          final current = state as PatientDashboardLoaded;
          emit(PatientDashboardLoaded(orders: current.orders, profile: profile));
        }
      },
    );
  }

  Future<void> _onRefreshOrders(RefreshOrders event, Emitter<PatientState> emit) async {
    final ordersResult = await getPatientOrdersUseCase.call();
    final orders = ordersResult.fold((l) => <OrderEntity>[], (r) => r);
    if (state is PatientDashboardLoaded) {
      final current = state as PatientDashboardLoaded;
      emit(PatientDashboardLoaded(orders: orders, profile: current.profile));
    }
  }
}
