import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/nurse_order_model.dart';
import '../repositories/nurse_repository.dart';

class AcceptOrderUseCase {
  final NurseRepository _repository;

  AcceptOrderUseCase(this._repository);

  Future<Either<Failure, NurseOrderModel>> call(String id) {
    return _repository.acceptOrder(id);
  }
}
