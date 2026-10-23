import 'package:equatable/equatable.dart';

import '../../domain/entities/booking_entity.dart';

enum BookingSubmitStatus { initial, loading, success, failure, duplicate, unavailable }

class BookingState extends Equatable {
  final BookingSubmitStatus submitStatus;
  final String? submitError;
  final BookingEntity? createdBooking;

  // Cancellation
  final bool isCancelling;
  final String? cancelError;
  final bool cancelSuccess;

  const BookingState({
    this.submitStatus = BookingSubmitStatus.initial,
    this.submitError,
    this.createdBooking,
    this.isCancelling = false,
    this.cancelError,
    this.cancelSuccess = false,
  });

  BookingState copyWith({
    BookingSubmitStatus? submitStatus,
    String? submitError,
    BookingEntity? createdBooking,
    bool? isCancelling,
    String? cancelError,
    bool? cancelSuccess,
    bool clearSubmitError = false,
    bool clearCancelError = false,
    bool clearCreatedBooking = false,
  }) {
    return BookingState(
      submitStatus: submitStatus ?? this.submitStatus,
      submitError:
          clearSubmitError ? null : (submitError ?? this.submitError),
      createdBooking:
          clearCreatedBooking ? null : (createdBooking ?? this.createdBooking),
      isCancelling: isCancelling ?? this.isCancelling,
      cancelError: clearCancelError ? null : (cancelError ?? this.cancelError),
      cancelSuccess: cancelSuccess ?? this.cancelSuccess,
    );
  }

  @override
  List<Object?> get props => [
    submitStatus,
    submitError,
    createdBooking,
    isCancelling,
    cancelError,
    cancelSuccess,
  ];
}

