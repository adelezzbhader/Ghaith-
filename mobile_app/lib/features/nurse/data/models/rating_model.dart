import 'package:equatable/equatable.dart';
import '../../domain/entities/rating_entity.dart';

class RatingModel extends Equatable {
  final String id;
  final String orderId;
  final String patientName;
  final int rating;
  final String? comment;
  final String date;

  const RatingModel({
    required this.id,
    required this.orderId,
    required this.patientName,
    required this.rating,
    this.comment,
    required this.date,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    String id = (json['id'] as String?) ?? '';
    String orderId = (json['order'] as String?) ??
        (json['order_id'] as String?) ??
        (json['orderId'] as String?) ??
        '';
    String patientName;
    if (json['patient'] is Map<String, dynamic>) {
      final patient = json['patient'] as Map<String, dynamic>;
      patientName = (patient['full_name'] as String?) ??
          (patient['fullName'] as String?) ??
          (patient['name'] as String?) ??
          '';
    } else {
      patientName = (json['patient_name'] as String?) ??
          (json['patientName'] as String?) ??
          (json['patient'] as String?) ??
          '';
    }
    String? comment = json['comment'] as String? ?? json['feedback'] as String?;
    String date = (json['date'] as String?) ?? (json['created_at'] as String?) ?? '';
    int rating;
    if (json['score'] is int) {
      rating = json['score'] as int;
    } else if (json['score'] is String) {
      rating = int.tryParse(json['score'] as String) ?? 0;
    } else if (json['rating'] is int) {
      rating = json['rating'] as int;
    } else if (json['rating'] is String) {
      rating = int.tryParse(json['rating'] as String) ?? 0;
    } else if (json['rate'] is int) {
      rating = json['rate'] as int;
    } else if (json['rate'] is String) {
      rating = int.tryParse(json['rate'] as String) ?? 0;
    } else {
      rating = 0;
    }

    return RatingModel(
      id: id,
      orderId: orderId,
      patientName: patientName,
      rating: rating.clamp(1, 5),
      comment: comment,
      date: date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': orderId,
      'patient_name': patientName,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }

  RatingEntity toEntity() {
    return RatingEntity(
      id: id,
      orderId: orderId,
      patientName: patientName,
      rating: rating,
      comment: comment,
      date: date,
    );
  }

  @override
  List<Object?> get props => [id, orderId, patientName, rating, comment, date];
}
