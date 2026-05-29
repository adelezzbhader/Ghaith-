import 'package:equatable/equatable.dart';

class EarningsEntity extends Equatable {
  final double totalMonth;
  final double deducted;
  final double actual;
  final List<EarningsBreakdownEntity> breakdown;

  const EarningsEntity({
    this.totalMonth = 0.0,
    this.deducted = 0.0,
    this.actual = 0.0,
    this.breakdown = const [],
  });

  @override
  List<Object?> get props => [totalMonth, deducted, actual, breakdown];
}

class EarningsBreakdownEntity extends Equatable {
  final String date;
  final double amount;
  final String order;

  const EarningsBreakdownEntity({
    required this.date,
    required this.amount,
    required this.order,
  });

  @override
  List<Object?> get props => [date, amount, order];
}
