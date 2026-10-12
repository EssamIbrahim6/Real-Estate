import 'package:flutter/material.dart';
import 'package:real_estate_app/core/constants/app_colors.dart';

class Bottom extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final Color color;
  final VoidCallback? onTap;
  const Bottom({
    super.key,
    this.color = AppColors.greenColors,
    this.height = 190,
    this.width = 54,
    this.onTap,
    this.text = "Next",
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        color: color,
        child: Text(text),
      ),
    );
  }
}
