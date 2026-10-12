import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../estate/domain/entities/estate_entity.dart';
import '../../domain/entities/search_filter.dart';

enum SearchStatus { initial, loading, success, empty, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final SearchFilter filter;
  final List<EstateEntity> estates;
  final List<CategoryEntity> categories;
  final Failure? failure;
  final String? categoriesError;

  const SearchState({
    this.status = SearchStatus.initial,
    this.filter = const SearchFilter(),
    this.estates = const [],
    this.categories = const [],
    this.failure,
    this.categoriesError,
  });

  SearchState copyWith({
    SearchStatus? status,
    SearchFilter? filter,
    List<EstateEntity>? estates,
    List<CategoryEntity>? categories,
    Failure? failure,
    String? categoriesError,
    bool clearFailure = false,
    bool clearCategoriesError = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      estates: estates ?? this.estates,
      categories: categories ?? this.categories,
      failure: clearFailure ? null : failure ?? this.failure,
      categoriesError: clearCategoriesError
          ? null
          : categoriesError ?? this.categoriesError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    filter,
    estates,
    categories,
    failure,
    categoriesError,
  ];
}
