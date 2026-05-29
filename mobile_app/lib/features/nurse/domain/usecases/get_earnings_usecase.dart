import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/earnings_model.dart';
import '../repositories/nurse_repository.dart';

class GetEarningsUseCase {
  final NurseRepository _repository;

  GetEarningsUseCase(this._repository);

  Future<Either<Failure, EarningsModel>> call() {
    return _repository.getEarnings();
  }
}
