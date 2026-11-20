import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../estate/domain/entities/estate_entity.dart';

/// Interactive price badge / pin displayed at an estate's location on the map.
class EstateMapMarker extends StatelessWidget {
  final EstateEntity estate;
  final bool isSelected;
  final VoidCallback onTap;

  const EstateMapMarker({
    super.key,
    required this.estate,
    required this.isSelected,
    required this.onTap,
  });

  static String formatPrice(double price) {
    if (price >= 1000000) {
      final millions = price / 1000000;
      final formatted = millions
          .toStringAsFixed(1)
          .replaceAll(RegExp(r'\.0$'), '');
      return '$formatted M';
    } else if (price >= 1000) {
      final thousands = price / 1000;
      final formatted = thousands
          .toStringAsFixed(1)
          .replaceAll(RegExp(r'\.0$'), '');
      return '$formatted K';
    }
    return price.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final priceLabel = formatPrice(estate.price);
    final colors = Theme.of(context).colorScheme;
    final currency = AppLocalizations.of(context)?.commonEgp ?? 'EGP';
    final backgroundColor = isSelected ? colors.primary : colors.surface;
    final foregroundColor = isSelected ? colors.onPrimary : colors.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? colors.secondary : colors.surface,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(
                      alpha: isSelected ? 0.3 : 0.2,
                    ),
                    blurRadius: isSelected ? 10 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? Icons.location_on : Icons.home_rounded,
                    size: 14,
                    color: isSelected ? colors.secondary : colors.primary,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      '$currency $priceLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: foregroundColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Pin pointer notch
            CustomPaint(
              size: const Size(11, 6),
              painter: _TrianglePainter(color: backgroundColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      color != oldDelegate.color;
}
