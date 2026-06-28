import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/nurse_repository.dart';

class GetNurseServicesUseCase {
  final NurseRepository _repository;

  GetNurseServicesUseCase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return _repository.getServices();
  }
}
