import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/nurse_repository.dart';

class GetNurseStatsUseCase {
  final NurseRepository _repository;

  GetNurseStatsUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return _repository.getStats();
  }
}
