import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/booking_entity.dart';
import '../cubit/booking_cubit.dart';
import '../widgets/booking_status_badge.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BookingEntity booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _lastCancelSuccess = false;

  void _confirmCancel(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx);
    showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n?.bookingCancelTitle ?? 'Cancel Booking?'),
        content: Text(
          l10n?.bookingCancelConfirm ??
              'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n?.commonCancel ?? 'Keep Booking'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop(true);
              final uid = FirebaseAuth.instance.currentUser?.uid;
              final langCode = Localizations.localeOf(ctx).languageCode;
              ctx.read<BookingCubit>().cancelBooking(
                bookingId: widget.booking.id,
                requesterId: uid ?? '',
                agentUserId: widget.booking.agentUserId,
                estateTitle: widget.booking.localizedEstateTitle(langCode),
              );
            },
            child: Text(l10n?.bookingCancelButton ?? 'Cancel Booking'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final booking = widget.booking;
    final dateStr =
        DateFormat('EEEE, MMMM d, yyyy').format(booking.bookingDate);

    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (_lastCancelSuccess == state.cancelSuccess) return;
        _lastCancelSuccess = state.cancelSuccess;
        if (state.cancelSuccess) {
          AppFeedback.success(
            context,
            l10n?.bookingCancelSuccess ?? 'Booking cancelled.',
          );
          if (context.canPop()) context.pop(true);
        } else if (state.cancelError != null) {
          AppFeedback.error(context, state.cancelError!);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.bookingDetailsTitle ?? 'Booking Details'),
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            // Status Row
            Row(
              children: [
                Text(
                  l10n?.bookingStatusLabel ?? 'Status',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                BookingStatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 20),

            // Estate Card
            _InfoCard(
              title: l10n?.bookingPropertySnapshot ?? 'Property',
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: booking.estateCoverImage.isNotEmpty
                          ? Image.network(
                              booking.estateCoverImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: colors.surfaceContainerLow,
                                child: Icon(
                                  Icons.home_outlined,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            )
                          : Container(
                              color: colors.surfaceContainerLow,
                              child: Icon(
                                Icons.home_outlined,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.localizedEstateTitle(langCode),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.estateAddress,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'EGP ${booking.estatePrice.toInt()}${booking.estatePricePeriod != null ? ' / ${booking.estatePricePeriod}' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colors.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Schedule
            _InfoCard(
              title: l10n?.bookingScheduleSection ?? 'Visit Schedule',
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: l10n?.bookingDateLabel ?? 'Date',
                    value: dateStr,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: l10n?.bookingTimeSlotLabel ?? 'Time Slot',
                    value: booking.timeSlot,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Customer
            _InfoCard(
              title: l10n?.bookingCustomerSection ?? 'Contact',
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: l10n?.bookingCustomerName ?? 'Name',
                    value: booking.customerName,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: l10n?.bookingCustomerEmail ?? 'Email',
                    value: booking.customerEmail,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: l10n?.bookingCustomerPhone ?? 'Phone',
                    value: booking.customerPhone,
                  ),
                ],
              ),
            ),

            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 14),
              _InfoCard(
                title: l10n?.bookingNotesLabel ?? 'Notes',
                child: Text(
                  booking.notes!,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
        bottomNavigationBar: booking.status.isCancellable
            ? _CancelBar(onCancel: () => _confirmCancel(context))
            : null,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _CancelBar extends StatelessWidget {
  final VoidCallback onCancel;

  const _CancelBar({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final isLoading = state.isCancelling;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: AppButton(
            text: l10n?.bookingCancelButton ?? 'Cancel Booking',
            type: AppButtonType.outlined,
            isLoading: isLoading,
            onPressed: isLoading ? null : onCancel,
          ),
        );
      },
    );
  }
}

