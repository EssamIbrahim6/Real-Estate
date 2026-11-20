import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/smart_search_ai_service.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/entities/smart_search_parser.dart';
import '../../domain/repositories/search_repository.dart';
import '../../../category/domain/repositories/category_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _searchRepository;
  final CategoryRepository _categoryRepository;
  final SmartSearchAiService? _aiService;

  int _searchGeneration = 0;

  SearchCubit({
    required this._searchRepository,
    required this._categoryRepository,
    this._aiService,
  }) : super(const SearchState());

  Future<void> loadCategories() async {
    final result = await _categoryRepository.getCategories();
    if (isClosed) return;
    emit(
      state.copyWith(
        categories: result.data ?? const [],
        categoriesError: result.failure?.message,
        clearCategoriesError: result.failure == null,
      ),
    );
  }

  Future<void> search(SearchFilter filter) async {
    if (!filter.hasSearchCriteria) {
      reset();
      return;
    }

    final generation = ++_searchGeneration;

    emit(
      state.copyWith(
        status: SearchStatus.loading,
        filter: filter,
        clearFailure: true,
      ),
    );

    final result = await _searchRepository.search(filter);

    if (isClosed || generation != _searchGeneration) return;

    if (result.failure != null) {
      emit(
        state.copyWith(
          status: SearchStatus.failure,
          failure: result.failure,
          estates: const [],
        ),
      );
      return;
    }

    final estates = result.data ?? const [];
    emit(
      state.copyWith(
        status: estates.isEmpty ? SearchStatus.empty : SearchStatus.success,
        estates: estates,
        clearFailure: true,
      ),
    );
  }

  Future<void> smartSearch(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      await search(_withQuery(state.filter, null));
      return;
    }

    final generation = ++_searchGeneration;
    emit(state.copyWith(status: SearchStatus.loading, clearFailure: true));

    if (_aiService == null) {
      final fallbackFilter = SmartSearchParser.parse(
        trimmedQuery,
        existing: state.filter,
      );
      await search(fallbackFilter);
      return;
    }
    try {
      final criteria = await _aiService.parse(trimmedQuery);
      if (isClosed || generation != _searchGeneration) return;

      if (criteria.intent == 'clarify' &&
          criteria.clarificationQuestion != null) {
        emit(state.copyWith(status: SearchStatus.success, failure: null));
        return;
      }

      final filter = criteria.toSearchFilter(
        state.filter,
        queryOverride: trimmedQuery,
      );
      await search(filter);
    } catch (e) {
      if (isClosed || generation != _searchGeneration) return;
      final fallbackFilter = SmartSearchParser.parse(
        trimmedQuery,
        existing: state.filter,
      );
      await search(fallbackFilter);
    }
  }

  void reset() {
    _searchGeneration++;
    emit(
      state.copyWith(
        status: SearchStatus.initial,
        filter: const SearchFilter(),
        estates: const [],
        clearFailure: true,
      ),
    );
  }

  Future<void> retry() => search(state.filter);

  SearchFilter _withQuery(SearchFilter filter, String? query) => SearchFilter(
    query: query,
    categoryId: filter.categoryId,
    city: filter.city,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
    bedrooms: filter.bedrooms,
    bathrooms: filter.bathrooms,
    isFurnished: filter.isFurnished,
    listingType: filter.listingType,
    isAvailable: filter.isAvailable,
  );
}
