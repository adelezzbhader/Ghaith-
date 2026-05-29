import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

class NurseOrderModel extends Equatable {
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

  const NurseOrderModel({
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

  factory NurseOrderModel.fromJson(Map<String, dynamic> json) {
    return NurseOrderModel.normalizeOrder(json);
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'جاري المعالجة';
      case 'completed':
        return 'منجزة';
      case 'cancelled':
        return 'ملغية';
      case 'awaiting_completion':
        return 'بانتظار التأكيد';
      case 'in_progress':
        return 'قيد التنفيذ';
      default:
        return 'نشطة';
    }
  }

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress' || status == 'pending';
  bool get isAwaitingCompletion => status == 'awaiting_completion';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  factory NurseOrderModel.normalizeOrder(Map<String, dynamic> json) {
    String patientName;
    String patientPhone;
    String patientAddress;
    List<String> services;
    double totalPrice;
    String date;

    if (json['patient'] is Map<String, dynamic>) {
      final patient = json['patient'] as Map<String, dynamic>;
      patientName = (patient['name'] as String?) ?? (patient['full_name'] as String?) ?? '';
      patientPhone = (patient['phone'] as String?) ?? '';
      patientAddress = (patient['address'] as String?) ?? '';
    } else {
      patientName = (json['patient_name'] as String?) ?? (json['patientName'] as String?) ?? '';
      patientPhone = (json['patient_phone'] as String?) ?? (json['patientPhone'] as String?) ?? '';
      patientAddress = (json['patient_address'] as String?) ?? (json['patientAddress'] as String?) ?? '';
    }

    if (json['items'] is List) {
      final items = json['items'] as List;
      services = items.map((item) {
        if (item is Map<String, dynamic>) {
          return (item['service_name'] as String?) ?? (item['serviceName'] as String?) ?? (item['name'] as String?) ?? '';
        }
        return item.toString();
      }).where((s) => s.isNotEmpty).toList();
    } else if (json['services'] is List) {
      services = (json['services'] as List).map((s) => s.toString()).toList();
    } else if (json['service_names'] is List) {
      services = (json['service_names'] as List).map((s) => s.toString()).toList();
    } else {
      services = [];
    }

    if (json['total_price'] is double) {
      totalPrice = json['total_price'] as double;
    } else if (json['total_price'] is int) {
      totalPrice = (json['total_price'] as int).toDouble();
    } else if (json['totalPrice'] is double) {
      totalPrice = json['totalPrice'] as double;
    } else if (json['totalPrice'] is int) {
      totalPrice = (json['totalPrice'] as int).toDouble();
    } else if (json['total_price'] is String) {
      totalPrice = double.tryParse(json['total_price'] as String) ?? 0.0;
    } else if (json['totalPrice'] is String) {
      totalPrice = double.tryParse(json['totalPrice'] as String) ?? 0.0;
    } else {
      totalPrice = 0.0;
    }

    date = (json['date'] as String?) ??
        (json['created_at'] as String?) ??
        (json['createdAt'] as String?) ??
        '';

    return NurseOrderModel(
      id: (json['id'] as String?) ?? (json['pk'] as String?) ?? (json['_id'] as String?) ?? '',
      orderNumber: json['order_number'] as String? ?? json['orderNumber'] as String?,
      patientName: patientName,
      patientPhone: patientPhone,
      patientAddress: patientAddress,
      services: services,
      area: (json['area'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'active',
      totalPrice: totalPrice,
      date: date,
      nurseName: json['nurse_name'] as String? ?? json['nurseName'] as String?,
      rating: json['rating'] is int
          ? json['rating'] as int
          : (json['rating'] is String ? int.tryParse(json['rating'] as String) : null),
      nurseConfirmedCompletion: json['nurse_confirmed_completion'] == true ||
          json['nurseConfirmedCompletion'] == true,
      patientConfirmedCompletion: json['patient_confirmed_completion'] == true ||
          json['patientConfirmedCompletion'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'patient_address': patientAddress,
      'services': services,
      'area': area,
      'status': status,
      'total_price': totalPrice,
      'date': date,
      'nurse_name': nurseName,
      'rating': rating,
      'nurse_confirmed_completion': nurseConfirmedCompletion,
      'patient_confirmed_completion': patientConfirmedCompletion,
    };
  }

  NurseOrderEntity toEntity() {
    return NurseOrderEntity(
      id: id,
      orderNumber: orderNumber,
      patientName: patientName,
      patientPhone: patientPhone,
      patientAddress: patientAddress,
      services: services,
      area: area,
      status: status,
      totalPrice: totalPrice,
      date: date,
      nurseName: nurseName,
      rating: rating,
      nurseConfirmedCompletion: nurseConfirmedCompletion,
      patientConfirmedCompletion: patientConfirmedCompletion,
    );
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
