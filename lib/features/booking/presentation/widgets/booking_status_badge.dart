import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/booking_status.dart';

class BookingStatusBadge extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = _resolve(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  (String, Color, Color) _resolve(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case BookingStatus.pending:
        return (
          l10n?.bookingStatusPending ?? 'Pending',
          colors.tertiary,
          colors.tertiaryContainer,
        );
      case BookingStatus.confirmed:
        return (
          l10n?.bookingStatusConfirmed ?? 'Confirmed',
          colors.primary,
          colors.primaryContainer,
        );
      case BookingStatus.cancelled:
        return (
          l10n?.bookingStatusCancelled ?? 'Cancelled',
          colors.error,
          colors.errorContainer,
        );
      case BookingStatus.completed:
        return (
          l10n?.bookingStatusCompleted ?? 'Completed',
          colors.secondary,
          colors.secondaryContainer,
        );
    }
  }
}
