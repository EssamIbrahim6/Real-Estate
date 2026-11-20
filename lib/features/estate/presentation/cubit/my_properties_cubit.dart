import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/estate_repository.dart';
import 'my_properties_state.dart';

class MyPropertiesCubit extends Cubit<MyPropertiesState> {
  final EstateRepository _estateRepository;

  MyPropertiesCubit({required this._estateRepository})
    : super(const MyPropertiesState());

  Future<void> loadProperties(String ownerId) async {
    final trimmed = ownerId.trim();
    if (trimmed.isEmpty) return;

    emit(
      state.copyWith(
        status: MyPropertiesStatus.loading,
        clearError: true,
        clearActionFeedback: true,
      ),
    );

    final result = await _estateRepository.getEstatesByOwnerId(trimmed);

    if (isClosed) return;

    if (result.failure != null) {
      emit(
        state.copyWith(
          status: MyPropertiesStatus.error,
          error: result.failure?.message ?? 'Failed to load your properties',
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: MyPropertiesStatus.success,
          properties: result.data ?? [],
          clearError: true,
        ),
      );
    }
  }

  Future<bool> deleteProperty({
    required String estateId,
    required String ownerId,
  }) async {
    final trimmedEstateId = estateId.trim();
    final trimmedOwnerId = ownerId.trim();
    if (trimmedEstateId.isEmpty || trimmedOwnerId.isEmpty) return false;

    emit(
      state.copyWith(
        isDeleting: true,
        deletingPropertyId: trimmedEstateId,
        clearActionFeedback: true,
        clearError: true,
      ),
    );

    final result = await _estateRepository.deleteEstate(
      estateId: trimmedEstateId,
      currentUid: trimmedOwnerId,
    );

    if (isClosed) return false;

    if (result.failure != null) {
      emit(
        state.copyWith(
          isDeleting: false,
          clearDeletingId: true,
          error: result.failure?.message ?? 'Failed to delete property',
        ),
      );
      return false;
    } else {
      final updatedList = state.properties
          .where((e) => e.id != trimmedEstateId)
          .toList(growable: false);

      emit(
        state.copyWith(
          isDeleting: false,
          clearDeletingId: true,
          properties: updatedList,
          actionFeedback: 'Property deleted successfully.',
        ),
      );
      return true;
    }
  }
}
