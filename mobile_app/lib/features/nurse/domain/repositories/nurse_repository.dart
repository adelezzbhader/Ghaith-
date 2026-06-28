import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/earnings_model.dart';
import '../../data/models/nurse_order_model.dart';
import '../../data/models/rating_model.dart';

abstract class NurseRepository {
  Future<Either<Failure, Map<String, dynamic>>> getProfile();
  Future<Either<Failure, List<NurseOrderModel>>> getActiveOrders();
  Future<Either<Failure, List<NurseOrderModel>>> getMyOrders();
  Future<Either<Failure, NurseOrderModel>> acceptOrder(String id);
  Future<Either<Failure, NurseOrderModel>> completeOrder(String id);
  Future<Either<Failure, void>> cancelOrder(String id);
  Future<Either<Failure, EarningsModel>> getEarnings();
  Future<Either<Failure, List<RatingModel>>> getRatings();
  Future<Either<Failure, Map<String, dynamic>>> getStats();
  Future<Either<Failure, List<Map<String, dynamic>>>> getServices();
}
