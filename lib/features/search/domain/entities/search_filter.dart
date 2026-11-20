import 'package:equatable/equatable.dart';

class SearchFilter extends Equatable {
  final String? query;
  final String? categoryId;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final int? bathrooms;
  final bool? isFurnished;
  final String? listingType;
  final bool? isAvailable;

  const SearchFilter({
    this.query,
    this.categoryId,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.bathrooms,
    this.isFurnished,
    this.listingType,
    this.isAvailable = true,
  });

  bool get hasSearchCriteria =>
      (query?.trim().isNotEmpty ?? false) ||
      (categoryId?.trim().isNotEmpty ?? false) ||
      (city?.trim().isNotEmpty ?? false) ||
      minPrice != null ||
      maxPrice != null ||
      bedrooms != null ||
      bathrooms != null ||
      isFurnished != null ||
      (listingType?.trim().isNotEmpty ?? false) ||
      isAvailable == false;

  SearchFilter clearFilters() => SearchFilter(query: query, isAvailable: true);

  @override
  List<Object?> get props => [
    query,
    categoryId,
    city,
    minPrice,
    maxPrice,
    bedrooms,
    bathrooms,
    isFurnished,
    listingType,
    isAvailable,
  ];
}
