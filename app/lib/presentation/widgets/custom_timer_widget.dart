import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";

import '../../core/resources/themes/app_colors.dart';

class CustomTimerWidget extends StatelessWidget {
  const CustomTimerWidget({
    required this.onPressed,
    required this.title,
    required this.image,
    super.key,
  });
  final Function() onPressed;
  final String title;
  final String image;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    double containerWidth = 160;
    double containerHeight = 150;
    double svgHeight = 70;
    double svgWidth = 60;
    double fontSize = 19;

    if (screenWidth > 600) {
      containerWidth = 207;
      containerHeight = 194;
      svgHeight = 90;
      svgWidth = 80;
      fontSize = 30;
    }

    return InkWell(
      onTap: onPressed,
      child: Container(
        width: containerWidth,
        height: containerHeight,
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadows: const [
            BoxShadow(
              color: AppColors.shadows,
              blurRadius: 7.32,
              offset: Offset(0, 7.32),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SvgPicture.asset(
                image,
                height: svgHeight,
                width: svgWidth,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: fontSize,
                  color: const Color(0xFFC8CE37),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
