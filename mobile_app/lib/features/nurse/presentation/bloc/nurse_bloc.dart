import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/earnings_model.dart';
import '../../data/models/nurse_order_model.dart';
import '../../data/models/rating_model.dart';
import '../../domain/usecases/accept_order_usecase.dart';
import '../../domain/usecases/cancel_nurse_order_usecase.dart';
import '../../domain/usecases/complete_nurse_order_usecase.dart';
import '../../domain/usecases/get_earnings_usecase.dart';
import '../../domain/usecases/get_nurse_active_orders_usecase.dart';
import '../../domain/usecases/get_nurse_my_orders_usecase.dart';
import '../../domain/usecases/get_nurse_profile_usecase.dart';
import '../../domain/usecases/get_nurse_stats_usecase.dart';
import '../../domain/usecases/get_ratings_usecase.dart';

part 'nurse_event.dart';
part 'nurse_state.dart';

class NurseBloc extends Bloc<NurseEvent, NurseState> {
  final GetNurseActiveOrdersUseCase _getActiveOrders;
  final GetNurseMyOrdersUseCase _getMyOrders;
  final AcceptOrderUseCase _acceptOrder;
  final CompleteNurseOrderUseCase _completeOrder;
  final CancelNurseOrderUseCase _cancelOrder;
  final GetEarningsUseCase _getEarnings;
  final GetRatingsUseCase _getRatings;
  final GetNurseProfileUseCase _getProfile;
  final GetNurseStatsUseCase _getStats;

  NurseBloc({
    required GetNurseActiveOrdersUseCase getActiveOrders,
    required GetNurseMyOrdersUseCase getMyOrders,
    required AcceptOrderUseCase acceptOrder,
    required CompleteNurseOrderUseCase completeOrder,
    required CancelNurseOrderUseCase cancelOrder,
    required GetEarningsUseCase getEarnings,
    required GetRatingsUseCase getRatings,
    required GetNurseProfileUseCase getProfile,
    required GetNurseStatsUseCase getStats,
  })  : _getActiveOrders = getActiveOrders,
        _getMyOrders = getMyOrders,
        _acceptOrder = acceptOrder,
        _completeOrder = completeOrder,
        _cancelOrder = cancelOrder,
        _getEarnings = getEarnings,
        _getRatings = getRatings,
        _getProfile = getProfile,
        _getStats = getStats,
        super(NurseInitial()) {
    on<LoadNurseDashboard>(_onLoadDashboard);
    on<AcceptNurseOrder>(_onAcceptOrder);
    on<CompleteNurseOrder>(_onCompleteOrder);
    on<CancelNurseOrder>(_onCancelOrder);
  }

  Future<void> _onLoadDashboard(LoadNurseDashboard event, Emitter<NurseState> emit) async {
    emit(NurseLoading());
    try {
      final statsResult = await _getStats();
      final activeOrdersResult = await _getActiveOrders();
      final myOrdersResult = await _getMyOrders();
      final earningsResult = await _getEarnings();
      final ratingsResult = await _getRatings();
      final profileResult = await _getProfile();

      final stats = statsResult.fold((l) => <String, dynamic>{}, (r) => r);
      final activeOrders = activeOrdersResult.fold((l) => <NurseOrderModel>[], (r) => r);
      final myOrders = myOrdersResult.fold((l) => <NurseOrderModel>[], (r) => r);
      final earnings = earningsResult.fold((l) => EarningsModel(totalMonth: 0, deducted: 0, actual: 0, breakdown: []), (r) => r);
      final ratings = ratingsResult.fold((l) => <RatingModel>[], (r) => r);
      final profile = profileResult.fold((l) => <String, dynamic>{}, (r) => r);

      emit(NurseDashboardLoaded(
        stats: stats,
        activeOrders: activeOrders,
        myOrders: myOrders,
        earnings: earnings,
        ratings: ratings,
        profile: profile,
      ));
    } catch (e) {
      emit(NurseError(message: 'حدث خطأ أثناء تحميل البيانات'));
    }
  }

  Future<void> _onAcceptOrder(AcceptNurseOrder event, Emitter<NurseState> emit) async {
    emit(NurseLoading());
    final result = await _acceptOrder(event.orderId);
    result.fold(
      (failure) => emit(NurseError(message: failure.message)),
      (order) {
        emit(NurseOrderActionSuccess(message: 'تم قبول الطلب بنجاح'));
        add(LoadNurseDashboard());
      },
    );
  }

  Future<void> _onCompleteOrder(CompleteNurseOrder event, Emitter<NurseState> emit) async {
    emit(NurseLoading());
    final result = await _completeOrder(event.orderId);
    result.fold(
      (failure) => emit(NurseError(message: failure.message)),
      (order) {
        emit(NurseOrderActionSuccess(message: 'تم تأكيد إتمام الطلب'));
        add(LoadNurseDashboard());
      },
    );
  }

  Future<void> _onCancelOrder(CancelNurseOrder event, Emitter<NurseState> emit) async {
    emit(NurseLoading());
    final result = await _cancelOrder(event.orderId);
    result.fold(
      (failure) => emit(NurseError(message: failure.message)),
      (_) {
        emit(NurseOrderActionSuccess(message: 'تم إلغاء الطلب'));
        add(LoadNurseDashboard());
      },
    );
  }
}
