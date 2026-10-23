import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';

// ─────────────────────────────── State ───────────────────────────────

enum BookingHistoryStatus { initial, loading, loaded, error }

class BookingHistoryState extends Equatable {
  final BookingHistoryStatus status;
  final List<BookingEntity> bookings;
  final String? error;

  const BookingHistoryState({
    this.status = BookingHistoryStatus.initial,
    this.bookings = const [],
    this.error,
  });

  BookingHistoryState copyWith({
    BookingHistoryStatus? status,
    List<BookingEntity>? bookings,
    String? error,
    bool clearError = false,
  }) {
    return BookingHistoryState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, bookings, error];
}

// ─────────────────────────────── Cubit ───────────────────────────────

class BookingHistoryCubit extends Cubit<BookingHistoryState> {
  final BookingRepository repository;
  StreamSubscription<List<BookingEntity>>? _sub;

  BookingHistoryCubit({required this.repository})
      : super(const BookingHistoryState());

  void loadBookings(String customerId) {
    emit(state.copyWith(status: BookingHistoryStatus.loading, clearError: true));
    _sub?.cancel();
    _sub = repository.watchCustomerBookings(customerId).listen(
      (bookings) {
        emit(
          state.copyWith(
            status: BookingHistoryStatus.loaded,
            bookings: bookings,
          ),
        );
      },
      onError: (Object e) {
        emit(
          state.copyWith(
            status: BookingHistoryStatus.error,
            error: e.toString(),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

