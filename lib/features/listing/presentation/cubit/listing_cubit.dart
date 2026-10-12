import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/category/domain/repositories/category_repository.dart';
import '../../../../features/estate/domain/entities/estate_entity.dart';
import '../../../../features/estate/domain/repositories/estate_repository.dart';
import 'listing_state.dart';

enum ListingType { all, featured, city, category, nearby }

class ListingRequest {
  final ListingType type;
  final String title;
  final String? categoryId;
  final String? city;
  final List<EstateEntity> estates;
  final Map<String, double> distancesKm;

  const ListingRequest({
    required this.type,
    required this.title,
    this.categoryId,
    this.city,
    this.estates = const [],
    this.distancesKm = const {},
  });
}

class ListingCubit extends Cubit<ListingState> {
  final EstateRepository _estateRepository;
  final CategoryRepository _categoryRepository;

  ListingCubit({
    required EstateRepository estateRepository,
    required CategoryRepository categoryRepository,
  }) : _estateRepository = estateRepository,
       _categoryRepository = categoryRepository,
       super(const ListingState());

  Future<void> load(ListingRequest? request) async {
    if (request == null) {
      emit(
        state.copyWith(
          status: ListingStatus.error,
          error:
              'The listing request is invalid. Return to Home and try again.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ListingStatus.loading,
        title: request.title,
        error: null,
      ),
    );

    if (request.type == ListingType.nearby) {
      emit(
        state.copyWith(
          status: ListingStatus.success,
          estates: request.estates,
          distancesKm: request.distancesKm,
        ),
      );
      return;
    }

    if (request.type == ListingType.category &&
        (request.categoryId == null || request.categoryId!.trim().isEmpty)) {
      emit(
        state.copyWith(
          status: ListingStatus.error,
          error: 'The category ID is invalid.',
        ),
      );
      return;
    }

    if (request.type == ListingType.category) {
      final categoryResult = await _categoryRepository.getCategoryById(
        request.categoryId!,
      );
      if (categoryResult.failure != null || categoryResult.data == null) {
        emit(
          state.copyWith(
            status: ListingStatus.error,
            error: categoryResult.failure?.message ?? 'Category not found.',
          ),
        );
        return;
      }
      emit(state.copyWith(title: categoryResult.data!.name));
    }

    final result = request.type == ListingType.featured
        ? await _estateRepository.getFeaturedEstates()
        : await _estateRepository.getEstates(
            categoryId: request.type == ListingType.category
                ? request.categoryId
                : null,
            city: request.type == ListingType.city ? request.city : null,
          );

    if (result.failure != null) {
      emit(
        state.copyWith(
          status: ListingStatus.error,
          error: result.failure!.message,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ListingStatus.success,
        estates: result.data ?? const [],
      ),
    );
  }
}
