import '../../../../core/utils/typedefs.dart';
import '../../../estate/domain/entities/estate_entity.dart';
import '../../../estate/domain/repositories/estate_repository.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final EstateRepository _estateRepository;

  const SearchRepositoryImpl(this._estateRepository);

  @override
  ResultFuture<List<EstateEntity>> search(SearchFilter filter) async {
    final result = await _estateRepository.getEstates(
      categoryId: _normalizeValue(filter.categoryId),
      city: _normalizeValue(filter.city),
      minPrice: filter.minPrice,
      maxPrice: filter.maxPrice,
      bedrooms: filter.bedrooms,
      bathrooms: filter.bathrooms,
      isFurnished: filter.isFurnished,
      listingType: _normalizeValue(filter.listingType),
      isAvailable: filter.isAvailable,
    );

    if (result.failure != null || result.data == null) {
      return (failure: result.failure, data: null);
    }

    final query = _normalizeSearchText(filter.query ?? '');
    if (query.isEmpty) {
      return (failure: null, data: result.data);
    }

    final terms = query.split(' ');
    final matches = result.data!.where((estate) {
      final searchableText = _normalizeSearchText(
        [
          estate.title,
          estate.titleEn ?? '',
          estate.titleAr ?? '',
          estate.description,
          estate.descriptionEn ?? '',
          estate.descriptionAr ?? '',
          estate.location.city,
          estate.location.cityEn ?? '',
          estate.location.cityAr ?? '',
          estate.location.address,
          estate.location.addressEn ?? '',
          estate.location.addressAr ?? '',
          ...estate.amenities,
        ].join(' '),
      );

      return terms.every(searchableText.contains);
    }).toList();

    return (failure: null, data: matches);
  }

  String? _normalizeValue(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String _normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
