import 'package:equatable/equatable.dart';

class RatingEntity extends Equatable {
  final String id;
  final String orderId;
  final String patientName;
  final int rating;
  final String? comment;
  final String date;

  const RatingEntity({
    required this.id,
    required this.orderId,
    required this.patientName,
    required this.rating,
    this.comment,
    required this.date,
  });

  @override
  List<Object?> get props => [id, orderId, patientName, rating, comment, date];
}
