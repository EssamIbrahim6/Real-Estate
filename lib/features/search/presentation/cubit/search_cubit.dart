import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../category/domain/repositories/category_repository.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/repositories/search_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _searchRepository;
  final CategoryRepository _categoryRepository;

  /// Incremented before every search call. The listener checks this before
  /// emitting to discard results from stale (superseded) requests.
  int _searchGeneration = 0;

  SearchCubit({
    required SearchRepository searchRepository,
    required CategoryRepository categoryRepository,
  }) : _searchRepository = searchRepository,
       _categoryRepository = categoryRepository,
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
    // Increment generation to invalidate any in-flight request.
    final generation = ++_searchGeneration;

    emit(
      state.copyWith(
        status: SearchStatus.loading,
        filter: filter,
        clearFailure: true,
      ),
    );

    final result = await _searchRepository.search(filter);

    // Discard if a newer search was already started.
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

  Future<void> retry() => search(state.filter);
}
