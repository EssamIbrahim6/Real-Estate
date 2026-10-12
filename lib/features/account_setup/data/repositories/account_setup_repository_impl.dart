import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/account_setup_repository.dart';
import '../datasources/account_setup_remote_data_source.dart';
import '../models/user_profile_model.dart';

class AccountSetupRepositoryImpl implements AccountSetupRepository {
  final AccountSetupRemoteDataSource _remoteDataSource;

  const AccountSetupRepositoryImpl(this._remoteDataSource);

  @override
  ResultFuture<UserProfileEntity> saveProfile(
    UserProfileEntity profile, {
    String? localImagePath,
  }) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      final result = await _remoteDataSource.saveProfile(
        model,
        localImagePath: localImagePath,
      );
      return (failure: null, data: result);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }

  @override
  ResultFuture<UserProfileEntity> getProfile(String userId) async {
    try {
      final result = await _remoteDataSource.getProfile(userId);
      return (failure: null, data: result);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }
}
