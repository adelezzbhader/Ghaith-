import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/nurse_repository.dart';

class GetNurseProfileUseCase {
  final NurseRepository _repository;

  GetNurseProfileUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return _repository.getProfile();
  }
}
