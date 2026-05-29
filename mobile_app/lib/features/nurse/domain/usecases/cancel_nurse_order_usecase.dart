import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/nurse_repository.dart';

class CancelNurseOrderUseCase {
  final NurseRepository _repository;

  CancelNurseOrderUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.cancelOrder(id);
  }
}
