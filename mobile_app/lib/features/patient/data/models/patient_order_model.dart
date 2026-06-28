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
    final nurseData = json['nurse'] is Map
        ? json['nurse'] as Map<String, dynamic>
        : null;
    final itemsData = json['items'] is List
        ? json['items'] as List<dynamic>
        : <dynamic>[];
    final servicesList = itemsData
        .map((item) => item is Map
            ? (item['service_name_ar'] ?? item['service_name_en'] ?? item['service_name'] ?? '').toString()
            : item.toString())
        .toList();

    return PatientOrderModel(
      id: json['id'].toString(),
      orderNumber: json['order_number']?.toString() ?? json['id'].toString(),
      patientName: patientData['full_name'] ?? json['patient_name'] ?? '',
      patientPhone: json['patient_phone'] ?? patientData['phone'] ?? '',
      patientAddress: json['address'] ?? json['patient_address'] ?? '',
      services: servicesList,
      area: json['area_name_ar'] ?? json['area_name'] ?? json['area'] ?? '',
      status: (json['status']?.toString() ?? 'active').toLowerCase(),
      totalPrice: double.tryParse(json['final_price']?.toString() ?? '') ??
                  double.tryParse(json['services_subtotal']?.toString() ?? '') ??
                  0,
      date: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      nurseName: nurseData?['full_name'] ?? json['nurse_name'],
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
      'final_price': totalPrice,
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
    final nurseData = json['nurse'] is Map
        ? json['nurse'] as Map<String, dynamic>
        : null;
    final itemsData = json['items'] is List
        ? json['items'] as List<dynamic>
        : <dynamic>[];

    final servicesList = itemsData.map((item) {
      if (item is Map) {
        return item['service_name_ar']?.toString() ?? item['service_name_en']?.toString() ?? item['service_name']?.toString() ?? '';
      }
      return item.toString();
    }).toList();

    final total = itemsData.fold<double>(0, (sum, item) {
      if (item is Map) {
        final p = item['total_price'] ?? item['unit_price'] ?? item['price'];
        return sum + ((p is num) ? p.toDouble() : double.tryParse(p?.toString() ?? '0') ?? 0);
      }
      return sum;
    });

    return PatientOrderModel(
      id: json['id'].toString(),
      orderNumber: json['order_number']?.toString() ?? json['id'].toString(),
      patientName: patientData['full_name'] ?? json['patient_name'] ?? '',
      patientPhone: json['patient_phone'] ?? patientData['phone'] ?? '',
      patientAddress: json['address'] ?? '',
      services: servicesList,
      area: json['area_name_ar'] ?? json['area_name'] ?? json['area'] ?? '',
      status: (json['status']?.toString() ?? 'active').toLowerCase(),
      totalPrice: double.tryParse(json['final_price']?.toString() ?? '') ??
                  double.tryParse(json['services_subtotal']?.toString() ?? '') ??
                  total,
      date: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      nurseName: nurseData?['full_name'] ?? json['nurse_name'],
      nurseConfirmedCompletion: json['nurse_confirmed_completion'] ?? false,
      patientConfirmedCompletion: json['patient_confirmed_completion'] ?? false,
      rating: json['rating'],
    );
  }
}
