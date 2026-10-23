import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/estate_entity.dart';
import '../../domain/repositories/estate_repository.dart';
import '../datasources/estate_remote_data_source.dart';
import '../models/estate_model.dart';

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

  @override
  ResultFuture<String> createEstate(EstateEntity estate) async {
    try {
      final model = estate is EstateModel
          ? estate
          : EstateModel(
              id: estate.id,
              title: estate.title,
              description: estate.description,
              titleEn: estate.titleEn,
              titleAr: estate.titleAr,
              descriptionEn: estate.descriptionEn,
              descriptionAr: estate.descriptionAr,
              price: estate.price,
              pricePeriod: estate.pricePeriod,
              listingType: estate.listingType,
              categoryId: estate.categoryId,
              agentId: estate.agentId,
              ownerId: estate.ownerId,
              userId: estate.userId,
              createdBy: estate.createdBy,
              publisherId: estate.publisherId,
              agentUserId: estate.agentUserId,
              location: estate.location is EstateLocationModel
                  ? (estate.location as EstateLocationModel)
                  : EstateLocationModel(
                      address: estate.location.address,
                      city: estate.location.city,
                      addressEn: estate.location.addressEn,
                      addressAr: estate.location.addressAr,
                      cityEn: estate.location.cityEn,
                      cityAr: estate.location.cityAr,
                      latitude: estate.location.latitude,
                      longitude: estate.location.longitude,
                      geohash: estate.location.geohash,
                    ),
              coverImage: estate.coverImage,
              images: estate.images,
              virtualTourUrl: estate.virtualTourUrl,
              bedrooms: estate.bedrooms,
              bathrooms: estate.bathrooms,
              area: estate.area,
              isFurnished: estate.isFurnished,
              amenities: estate.amenities,
              rating: estate.rating,
              reviewCount: estate.reviewCount,
              isFeatured: estate.isFeatured,
              isAvailable: estate.isAvailable,
              status: estate.status,
              createdAt: estate.createdAt ?? DateTime.now(),
              updatedAt: estate.updatedAt ?? DateTime.now(),
            );
      final id = await _remoteDataSource.createEstate(model);
      return (failure: null, data: id);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }
}
