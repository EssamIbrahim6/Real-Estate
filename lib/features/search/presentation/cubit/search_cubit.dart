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
    required SearchRepository searchRepository,
    required CategoryRepository categoryRepository,
    SmartSearchAiService? aiService,
  }) : _searchRepository = searchRepository,
       _categoryRepository = categoryRepository,
       _aiService = aiService,
       super(const SearchState());

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
    final generation = ++_searchGeneration;
    emit(state.copyWith(status: SearchStatus.loading, clearFailure: true));

    if (_aiService == null) {
      final fallbackFilter = SmartSearchParser.parse(query, existing: state.filter);
      await search(fallbackFilter);
      return;
    }
    try {
      final criteria = await _aiService.parse(query);
      if (isClosed || generation != _searchGeneration) return;

      if (criteria.intent == 'clarify' && criteria.clarificationQuestion != null) {
        emit(
          state.copyWith(
            status: SearchStatus.success,
            failure: null,
          ),
        );
        return;
      }

      final filter = criteria.toSearchFilter(state.filter, queryOverride: query);
      await search(filter);
    } catch (e) {
      if (isClosed || generation != _searchGeneration) return;
      final fallbackFilter = SmartSearchParser.parse(query, existing: state.filter);
      await search(fallbackFilter);
    }
  }

  Future<void> retry() => search(state.filter);
}