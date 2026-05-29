part of 'nurse_bloc.dart';

abstract class NurseState extends Equatable {
  const NurseState();

  @override
  List<Object?> get props => [];
}

class NurseInitial extends NurseState {
  const NurseInitial();
}

class NurseLoading extends NurseState {
  const NurseLoading();
}

class NurseDashboardLoaded extends NurseState {
  final Map<String, dynamic> stats;
  final List<NurseOrderModel> activeOrders;
  final List<NurseOrderModel> myOrders;
  final EarningsModel earnings;
  final List<RatingModel> ratings;
  final Map<String, dynamic> profile;

  const NurseDashboardLoaded({
    required this.stats,
    required this.activeOrders,
    required this.myOrders,
    required this.earnings,
    required this.ratings,
    required this.profile,
  });

  @override
  List<Object?> get props => [stats, activeOrders, myOrders, earnings, ratings, profile];
}

class NurseOrderActionSuccess extends NurseState {
  final String message;

  const NurseOrderActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class NurseError extends NurseState {
  final String message;

  const NurseError({required this.message});

  @override
  List<Object?> get props => [message];
}
