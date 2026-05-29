class OrderEntity {
  final String id;
  final String orderNumber;
  final String patientName;
  final String patientPhone;
  final String patientAddress;
  final List<String> services;
  final String area;
  final String status;
  final double totalPrice;
  final DateTime date;
  final String? nurseName;
  final bool nurseConfirmedCompletion;
  final bool patientConfirmedCompletion;
  final int? rating;

  OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.patientName,
    required this.patientPhone,
    required this.patientAddress,
    required this.services,
    required this.area,
    required this.status,
    required this.totalPrice,
    required this.date,
    this.nurseName,
    this.nurseConfirmedCompletion = false,
    this.patientConfirmedCompletion = false,
    this.rating,
  });
}
