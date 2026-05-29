import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/rating_model.dart';
import '../repositories/nurse_repository.dart';

class GetRatingsUseCase {
  final NurseRepository _repository;

  GetRatingsUseCase(this._repository);

  Future<Either<Failure, List<RatingModel>>> call() {
    return _repository.getRatings();
  }
}
