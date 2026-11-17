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
    final dateStr = DateFormat(
      'EEE, MMM d',
      langCode,
    ).format(booking.bookingDate);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 18),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant),
      ),
      color: colors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 178,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  booking.estateCoverImage.isNotEmpty
                      ? Image.network(
                          booking.estateCoverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(colors),
                        )
                      : _placeholder(colors),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xC9000000)],
                        stops: [0.35, 1],
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 14,
                    end: 14,
                    child: BookingStatusBadge(status: booking.status),
                  ),
                  PositionedDirectional(
                    start: 17,
                    end: 17,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        if (booking.estateAddress.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 15,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  booking.estateAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _BookingMeta(
                          icon: Icons.calendar_month_rounded,
                          label: dateStr,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _BookingMeta(
                          icon: Icons.schedule_rounded,
                          label: booking.timeSlot,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'EGP ${booking.estatePrice.toInt()}'
                          '${booking.estatePricePeriod == null ? '' : ' / ${booking.estatePricePeriod}'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.tertiary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: colors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      color: colors.surfaceContainerHigh,
      child: Icon(
        Icons.home_work_outlined,
        color: colors.onSurfaceVariant,
        size: 42,
      ),
    );
  }
}

class _BookingMeta extends StatelessWidget {
  const _BookingMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
