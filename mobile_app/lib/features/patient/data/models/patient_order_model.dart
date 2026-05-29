import '../../domain/entities/order_entity.dart';

class PatientOrderModel extends OrderEntity {
  PatientOrderModel({
    required super.id,
    required super.orderNumber,
    required super.patientName,
    required super.patientPhone,
    required super.patientAddress,
    required super.services,
    required super.area,
    required super.status,
    required super.totalPrice,
    required super.date,
    super.nurseName,
    super.nurseConfirmedCompletion,
    super.patientConfirmedCompletion,
    super.rating,
  });

  factory PatientOrderModel.fromJson(Map<String, dynamic> json) {
    final patientData = json['patient'] is Map
        ? json['patient'] as Map<String, dynamic>
        : <String, dynamic>{};
    final itemsData = json['items'] is List
        ? json['items'] as List<dynamic>
        : <dynamic>[];
    final servicesList = itemsData
        .map((item) => item is Map ? (item['service_name'] ?? item['service'] ?? '').toString() : item.toString())
        .toList();

    return PatientOrderModel(
      id: json['id'].toString(),
      orderNumber: json['order_number'] ?? json['id'].toString(),
      patientName: patientData['name'] ?? json['patient_name'] ?? '',
      patientPhone: patientData['phone'] ?? json['patient_phone'] ?? '',
      patientAddress: json['address'] ?? json['patient_address'] ?? '',
      services: servicesList,
      area: json['area_name'] ?? json['area'] ?? '',
      status: json['status'] ?? 'pending',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      date: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      nurseName: json['nurse_name'],
      nurseConfirmedCompletion: json['nurse_confirmed_completion'] ?? false,
      patientConfirmedCompletion: json['patient_confirmed_completion'] ?? false,
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'address': patientAddress,
      'services': services,
      'area': area,
      'status': status,
      'total_price': totalPrice,
      'created_at': date.toIso8601String(),
      'nurse_name': nurseName,
      'nurse_confirmed_completion': nurseConfirmedCompletion,
      'patient_confirmed_completion': patientConfirmedCompletion,
      'rating': rating,
    };
  }

  static PatientOrderModel fromNestedJson(Map<String, dynamic> json) {
    final patientData = json['patient'] is Map
        ? json['patient'] as Map<String, dynamic>
        : <String, dynamic>{};
    final itemsData = json['items'] is List
        ? json['items'] as List<dynamic>
        : <dynamic>[];

    final servicesList = itemsData.map((item) {
      if (item is Map) {
        return item['service_name']?.toString() ?? item['service']?.toString() ?? '';
      }
      return item.toString();
    }).toList();

    final total = itemsData.fold<double>(0, (sum, item) {
      if (item is Map) {
        return sum + (item['price'] ?? 0).toDouble();
      }
      return sum;
    });

    return PatientOrderModel(
      id: json['id'].toString(),
      orderNumber: json['order_number'] ?? json['id'].toString(),
      patientName: patientData['name'] ?? json['patient_name'] ?? '',
      patientPhone: patientData['phone'] ?? json['patient_phone'] ?? '',
      patientAddress: json['address'] ?? '',
      services: servicesList,
      area: json['area_name'] ?? json['area'] ?? '',
      status: json['status'] ?? 'pending',
      totalPrice: json['total_price'] != null ? (json['total_price'] as num).toDouble() : total,
      date: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      nurseName: json['nurse_name'],
      nurseConfirmedCompletion: json['nurse_confirmed_completion'] ?? false,
      patientConfirmedCompletion: json['patient_confirmed_completion'] ?? false,
      rating: json['rating'],
    );
  }
}
