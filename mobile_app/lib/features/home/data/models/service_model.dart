import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  ServiceModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.price,
    super.icon,
    super.perHour,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'].toString(),
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      icon: json['icon'] ?? '💉',
      perHour: json['per_hour'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'price': price,
      'icon': icon,
      'per_hour': perHour,
    };
  }
}
