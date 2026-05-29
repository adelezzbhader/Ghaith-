import 'package:equatable/equatable.dart';

class NurseOrderEntity extends Equatable {
  final String id;
  final String? orderNumber;
  final String patientName;
  final String patientPhone;
  final String patientAddress;
  final List<String> services;
  final String area;
  final String status;
  final double totalPrice;
  final String date;
  final String? nurseName;
  final int? rating;
  final bool nurseConfirmedCompletion;
  final bool patientConfirmedCompletion;

  const NurseOrderEntity({
    required this.id,
    this.orderNumber,
    required this.patientName,
    required this.patientPhone,
    required this.patientAddress,
    required this.services,
    required this.area,
    required this.status,
    required this.totalPrice,
    required this.date,
    this.nurseName,
    this.rating,
    this.nurseConfirmedCompletion = false,
    this.patientConfirmedCompletion = false,
  });

  bool get isActive => status == 'active' || status == 'new';

  bool get isInProgress => status == 'in_progress' || status == 'accepted';

  bool get isAwaitingCompletion => status == 'awaiting_completion';

  bool get isCompleted => status == 'completed' || (nurseConfirmedCompletion && patientConfirmedCompletion);

  bool get isCancelled => status == 'cancelled';

  String get statusText {
    switch (status) {
      case 'active':
      case 'new':
        return 'نشط';
      case 'accepted':
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'awaiting_completion':
        return 'بانتظار التأكيد';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        patientName,
        patientPhone,
        patientAddress,
        services,
        area,
        status,
        totalPrice,
        date,
        nurseName,
        rating,
        nurseConfirmedCompletion,
        patientConfirmedCompletion,
      ];
}
