import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brandNavy : AppColors.brandGreen,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.brandGreen : Colors.white,
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? Icons.location_on : Icons.home_rounded,
                    size: 13,
                    color: isSelected
                        ? AppColors.brandGreen
                        : AppColors.brandNavy,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      'EGP $priceLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : AppColors.brandNavy,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Pin pointer notch
            CustomPaint(
              size: const Size(10, 6),
              painter: _TrianglePainter(
                color: isSelected ? AppColors.brandNavy : AppColors.brandGreen,
              ),
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
