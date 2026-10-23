import 'package:flutter/material.dart';

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
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  (String, Color, Color) _resolve(BuildContext context) {
    switch (status) {
      case BookingStatus.pending:
        return ('Pending', const Color(0xFFB45309), const Color(0xFFFEF3C7));
      case BookingStatus.confirmed:
        return ('Confirmed', const Color(0xFF065F46), const Color(0xFFD1FAE5));
      case BookingStatus.cancelled:
        return ('Cancelled', const Color(0xFF991B1B), const Color(0xFFFEE2E2));
      case BookingStatus.completed:
        return ('Completed', const Color(0xFF1D4ED8), const Color(0xFFDBEAFE));
    }
  }
}

