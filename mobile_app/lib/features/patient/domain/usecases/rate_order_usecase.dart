import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import 'package:mongez/features/patient/domain/repositories/patient_repository.dart';

class RateOrderUseCase {
  final PatientRepository repository;

  RateOrderUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, {required int score, String? comment}) {
    return repository.rateOrder(id, score: score, comment: comment);
  }
}
