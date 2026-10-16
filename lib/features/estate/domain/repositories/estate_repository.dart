import '../../../../core/utils/typedefs.dart';
import '../entities/estate_entity.dart';

abstract class EstateRepository {
  ResultFuture<List<EstateEntity>> getFeaturedEstates();

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
  });

  ResultFuture<List<EstateEntity>> getEstatesByAgentId(String agentId);

  /// Fetches a single estate by its unique document ID.
  ResultFuture<EstateEntity> getEstateById(String id);

  /// Creates or publishes an estate listing.
  ResultFuture<String> createEstate(EstateEntity estate);
}
