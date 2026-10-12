import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/account_setup_repository.dart';

class SaveAccountSetupParams {
  final UserProfileEntity profile;
  final String? localImagePath;

  const SaveAccountSetupParams({required this.profile, this.localImagePath});
}

class SaveAccountSetupUseCase
    extends
        UseCase<
          ({dynamic failure, UserProfileEntity? data}),
          SaveAccountSetupParams
        > {
  final AccountSetupRepository _repository;
  const SaveAccountSetupUseCase(this._repository);

  @override
  ResultFuture<UserProfileEntity> call(SaveAccountSetupParams params) {
    return _repository.saveProfile(
      params.profile,
      localImagePath: params.localImagePath,
    );
  }
}
