import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/estate_entity.dart';
import '../../domain/repositories/estate_repository.dart';
import '../datasources/estate_remote_data_source.dart';

class EstateRepositoryImpl implements EstateRepository {
  final EstateRemoteDataSource _remoteDataSource;

  const EstateRepositoryImpl(this._remoteDataSource);
  @override
  ResultFuture<EstateEntity> getEstateById(String id) async {
    try {
      final estate = await _remoteDataSource.getEstateById(id);
      return (failure: null, data: estate);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }

  @override
  ResultFuture<List<EstateEntity>> getFeaturedEstates() async {
    try {
      final estates = await _remoteDataSource.getFeaturedEstates();
      return (failure: null, data: estates);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }

  @override
  ResultFuture<List<EstateEntity>> getEstates({
    String? categoryId,
    String? city,
    int? limit,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    bool? isFurnished,
    String? listingType,
    bool? isAvailable,
  }) async {
    try {
      final estates = await _remoteDataSource.getEstates(
        categoryId: categoryId,
        city: city,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        isFurnished: isFurnished,
        listingType: listingType,
        isAvailable: isAvailable,
      );
      return (failure: null, data: estates);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }

  @override
  ResultFuture<List<EstateEntity>> getEstatesByAgentId(String agentId) async {
    try {
      final estates = await _remoteDataSource.getEstatesByAgentId(agentId);
      return (failure: null, data: estates);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }
}
