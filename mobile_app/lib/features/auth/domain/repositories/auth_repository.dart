import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(
      String email, String password, String role);

  Future<Either<Failure, UserEntity>> registerPatient(
      Map<String, dynamic> data);

  Future<Either<Failure, void>> registerNurse(
    Map<String, dynamic> data, {
    XFile? photo,
    XFile? certificate,
    XFile? syndicateCard,
  });

  Future<Either<Failure, void>> logout();
}
