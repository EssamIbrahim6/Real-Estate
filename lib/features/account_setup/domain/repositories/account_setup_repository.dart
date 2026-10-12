import '../../../../core/utils/typedefs.dart';
import '../entities/user_profile_entity.dart';

abstract class AccountSetupRepository {
  ResultFuture<UserProfileEntity> saveProfile(
    UserProfileEntity profile, {
    String? localImagePath,
  });
  ResultFuture<UserProfileEntity> getProfile(String userId);
}
