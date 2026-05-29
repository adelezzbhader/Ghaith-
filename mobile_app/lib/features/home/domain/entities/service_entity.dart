class ServiceEntity {
  final String id;
  final String nameAr;
  final String nameEn;
  final double price;
  final String icon;
  final bool perHour;

  ServiceEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    this.icon = '💉',
    this.perHour = false,
  });
}
