import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/patient/domain/entities/order_entity.dart';

class PatientProfile {
  final String name;
  final String phone;
  final String email;
  final String? gender;
  final String address;

  PatientProfile({
    required this.name,
    required this.phone,
    required this.email,
    this.gender,
    this.address = '',
  });
}

abstract class PatientRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders();
  Future<Either<Failure, OrderEntity>> createOrder({
    required String areaId,
    required String address,
    required List<String> services,
    int? fullCareHours,
    String? fullCareGender,
  });
  Future<Either<Failure, OrderEntity>> completeOrder(String id);
  Future<Either<Failure, OrderEntity>> cancelOrder(String id);
  Future<Either<Failure, void>> rateOrder(String id, {required int score, String? comment});
  Future<Either<Failure, PatientProfile>> getProfile();
  Future<Either<Failure, PatientProfile>> updateAddress(String address);
}
