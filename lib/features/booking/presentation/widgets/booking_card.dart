import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/booking_entity.dart';
import 'booking_status_badge.dart';

class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final String langCode;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.booking,
    required this.langCode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = booking.localizedEstateTitle(langCode);
    final dateStr = DateFormat('EEE, MMM d, yyyy').format(booking.bookingDate);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      color: colors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child:
                          booking.estateCoverImage.isNotEmpty
                              ? Image.network(
                                booking.estateCoverImage,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, _, _) => _placeholder(colors),
                              )
                              : _placeholder(colors),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.estateAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  BookingStatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: colors.outlineVariant, height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: colors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time_rounded, size: 14, color: colors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.timeSlot,
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      color: colors.surfaceContainerLow,
      child: Icon(Icons.home_outlined, color: colors.onSurfaceVariant, size: 28),
    );
  }
}

