import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/booking_repository.dart';
import 'booking_state.dart';

export 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository repository;

  BookingCubit({required this.repository})
      : super(const BookingState());

  void reset() => emit(const BookingState());

  Future<void> submitBooking({
    required String estateId,
    required String estateTitle,
    required String? estateTitleEn,
    required String? estateTitleAr,
    required String estateCoverImage,
    required String estateAddress,
    required double estatePrice,
    required String? estatePricePeriod,
    required String listingType,
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String agentId,
    required String? agentUserId,
    required DateTime bookingDate,
    required String timeSlot,
    String? notes,
  }) async {
    if (state.submitStatus == BookingSubmitStatus.loading) return;

    emit(
      state.copyWith(
        submitStatus: BookingSubmitStatus.loading,
        clearSubmitError: true,
        clearCreatedBooking: true,
      ),
    );

    // 1. Duplicate check
    final dupResult = await repository.checkDuplicateBooking(
      estateId: estateId,
      customerId: customerId,
      bookingDate: bookingDate,
      timeSlot: timeSlot,
    );
    if (dupResult.failure != null) {
      emit(
        state.copyWith(
          submitStatus: BookingSubmitStatus.failure,
          submitError: dupResult.failure!.message,
        ),
      );
      return;
    }
    if (dupResult.data == true) {
      emit(
        state.copyWith(
          submitStatus: BookingSubmitStatus.duplicate,
          submitError: 'You have already booked this property for the selected date and time.',
        ),
      );
      return;
    }

    // 2. Create booking
    final result = await repository.createBooking(
      estateId: estateId,
      estateTitle: estateTitle,
      estateTitleEn: estateTitleEn,
      estateTitleAr: estateTitleAr,
      estateCoverImage: estateCoverImage,
      estateAddress: estateAddress,
      estatePrice: estatePrice,
      estatePricePeriod: estatePricePeriod,
      listingType: listingType,
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      agentId: agentId,
      agentUserId: agentUserId,
      bookingDate: bookingDate,
      timeSlot: timeSlot,
      notes: notes,
    );

    if (result.failure != null) {
      emit(
        state.copyWith(
          submitStatus: BookingSubmitStatus.failure,
          submitError: result.failure!.message,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        submitStatus: BookingSubmitStatus.success,
        createdBooking: result.data,
      ),
    );
  }

  Future<void> cancelBooking({
    required String bookingId,
    required String requesterId,
  }) async {
    if (state.isCancelling) return;
    emit(
      state.copyWith(
        isCancelling: true,
        clearCancelError: true,
        cancelSuccess: false,
      ),
    );

    final result = await repository.cancelBooking(
      bookingId: bookingId,
      requesterId: requesterId,
    );

    if (result.failure != null) {
      emit(
        state.copyWith(
          isCancelling: false,
          cancelError: result.failure!.message,
        ),
      );
      return;
    }

    emit(state.copyWith(isCancelling: false, cancelSuccess: true));
  }
}

