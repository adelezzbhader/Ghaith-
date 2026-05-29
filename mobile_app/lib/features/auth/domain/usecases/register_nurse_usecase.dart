import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mongez/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class RegisterNurseUseCase {
  final AuthRepository repository;

  RegisterNurseUseCase(this.repository);

  Future<Either<Failure, void>> call(
    Map<String, dynamic> data, {
    File? photo,
    File? certificate,
    File? syndicateCard,
  }) =>
      repository.registerNurse(
        data,
        photo: photo,
        certificate: certificate,
        syndicateCard: syndicateCard,
      );
}
