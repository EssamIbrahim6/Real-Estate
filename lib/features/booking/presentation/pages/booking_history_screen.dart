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
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
              itemCount: state.bookings.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  final colors = Theme.of(context).colorScheme;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                        colors: [
                          colors.primary,
                          colors.primary.withValues(alpha: 0.78),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: colors.onPrimary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Icon(
                            Icons.event_available_rounded,
                            color: colors.onPrimary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            l10n?.bookingHistorySummary ??
                                'Keep your property visits in one place.',
                            style: TextStyle(
                              color: colors.onPrimary.withValues(alpha: 0.9),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: colors.onPrimary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            l10n?.bookingHistoryCount(state.bookings.length) ??
                                '${state.bookings.length}',
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final booking = state.bookings[i - 1];
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
