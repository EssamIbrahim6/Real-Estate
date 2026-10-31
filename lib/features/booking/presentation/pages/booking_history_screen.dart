import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_skeleton.dart';
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
            return const BookingHistorySkeleton();
          }

          if (state.status == BookingHistoryStatus.error) {
            return AppErrorView(
              message: state.error ?? 'Could not load bookings.',
              onRetry: () {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  context.read<BookingHistoryCubit>().loadBookings(uid);
                }
              },
            );
          }

          if (state.bookings.isEmpty) {
            return AppEmptyState(
              icon: Icons.event_available_outlined,
              title: l10n?.myBookingsEmpty ?? 'No bookings yet',
              description: 'Book a visit to any property to get started.',
              actionLabel: l10n?.navHome ?? 'Browse properties',
              onAction: () => context.go('/home'),
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
