import 'package:equatable/equatable.dart';
import '../../domain/entities/earnings_entity.dart';

class EarningsBreakdownModel extends Equatable {
  final String date;
  final double amount;
  final String order;

  const EarningsBreakdownModel({
    required this.date,
    required this.amount,
    required this.order,
  });

  factory EarningsBreakdownModel.fromJson(Map<String, dynamic> json) {
    double amount;
    if (json['amount'] is double) {
      amount = json['amount'] as double;
    } else if (json['amount'] is int) {
      amount = (json['amount'] as int).toDouble();
    } else if (json['amount'] is String) {
      amount = double.tryParse(json['amount'] as String) ?? 0.0;
    } else {
      amount = 0.0;
    }

    return EarningsBreakdownModel(
      date: (json['date'] as String?) ?? '',
      amount: amount,
      order: (json['order'] as String?) ?? (json['order_number'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'amount': amount,
      'order': order,
    };
  }

  EarningsBreakdownEntity toEntity() {
    return EarningsBreakdownEntity(
      date: date,
      amount: amount,
      order: order,
    );
  }

  @override
  List<Object?> get props => [date, amount, order];
}

class EarningsModel extends Equatable {
  final double totalMonth;
  final double deducted;
  final double actual;
  final List<EarningsBreakdownModel> breakdown;

  const EarningsModel({
    this.totalMonth = 0.0,
    this.deducted = 0.0,
    this.actual = 0.0,
    this.breakdown = const [],
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    double totalMonth;
    double deducted;
    double actual;

    if (json['total_month'] is double) {
      totalMonth = json['total_month'] as double;
    } else if (json['total_month'] is int) {
      totalMonth = (json['total_month'] as int).toDouble();
    } else if (json['total_month'] is String) {
      totalMonth = double.tryParse(json['total_month'] as String) ?? 0.0;
    } else if (json['totalMonth'] is double) {
      totalMonth = json['totalMonth'] as double;
    } else {
      totalMonth = 0.0;
    }

    if (json['deducted'] is double) {
      deducted = json['deducted'] as double;
    } else if (json['deducted'] is int) {
      deducted = (json['deducted'] as int).toDouble();
    } else if (json['deducted'] is String) {
      deducted = double.tryParse(json['deducted'] as String) ?? 0.0;
    } else {
      deducted = 0.0;
    }

    if (json['actual'] is double) {
      actual = json['actual'] as double;
    } else if (json['actual'] is int) {
      actual = (json['actual'] as int).toDouble();
    } else if (json['actual'] is String) {
      actual = double.tryParse(json['actual'] as String) ?? 0.0;
    } else {
      actual = 0.0;
    }

    List<EarningsBreakdownModel> breakdown = [];
    if (json['breakdown'] is List) {
      breakdown = (json['breakdown'] as List)
          .where((e) => e is Map<String, dynamic>)
          .map((e) => EarningsBreakdownModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['details'] is List) {
      breakdown = (json['details'] as List)
          .where((e) => e is Map<String, dynamic>)
          .map((e) => EarningsBreakdownModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return EarningsModel(
      totalMonth: totalMonth,
      deducted: deducted,
      actual: actual,
      breakdown: breakdown,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_month': totalMonth,
      'deducted': deducted,
      'actual': actual,
      'breakdown': breakdown.map((e) => e.toJson()).toList(),
    };
  }

  EarningsEntity toEntity() {
    return EarningsEntity(
      totalMonth: totalMonth,
      deducted: deducted,
      actual: actual,
      breakdown: breakdown.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  List<Object?> get props => [totalMonth, deducted, actual, breakdown];
}
