import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/nurse_order_model.dart';
import '../repositories/nurse_repository.dart';

class GetNurseMyOrdersUseCase {
  final NurseRepository _repository;

  GetNurseMyOrdersUseCase(this._repository);

  Future<Either<Failure, List<NurseOrderModel>>> call() {
    return _repository.getMyOrders();
  }
}
