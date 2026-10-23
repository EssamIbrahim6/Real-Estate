import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/booking_history_cubit.dart';
import '../widgets/booking_card.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<BookingHistoryCubit>().loadBookings(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.myBookingsTitle ?? 'My Bookings'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: BlocBuilder<BookingHistoryCubit, BookingHistoryState>(
        builder: (context, state) {
          if (state.status == BookingHistoryStatus.initial ||
              state.status == BookingHistoryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BookingHistoryStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.error ?? 'Could not load bookings.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null) {
                          context.read<BookingHistoryCubit>().loadBookings(uid);
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n?.commonRetry ?? 'Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.bookings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.myBookingsEmpty ?? 'No bookings yet.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Book a visit to any property to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                context.read<BookingHistoryCubit>().loadBookings(uid);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: state.bookings.length,
              itemBuilder: (context, i) {
                final booking = state.bookings[i];
                return BookingCard(
                  booking: booking,
                  langCode: langCode,
                  onTap: () => context.pushNamed(
                    AppRoutes.bookingDetailsName,
                    pathParameters: {'bookingId': booking.id},
                    extra: booking,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

