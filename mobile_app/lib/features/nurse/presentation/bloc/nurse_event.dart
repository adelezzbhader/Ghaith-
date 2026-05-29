part of 'nurse_bloc.dart';

abstract class NurseEvent extends Equatable {
  const NurseEvent();

  @override
  List<Object?> get props => [];
}

class LoadNurseDashboard extends NurseEvent {
  const LoadNurseDashboard();
}

class AcceptNurseOrder extends NurseEvent {
  final String orderId;

  const AcceptNurseOrder({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class CompleteNurseOrder extends NurseEvent {
  final String orderId;

  const CompleteNurseOrder({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class CancelNurseOrder extends NurseEvent {
  final String orderId;

  const CancelNurseOrder({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
