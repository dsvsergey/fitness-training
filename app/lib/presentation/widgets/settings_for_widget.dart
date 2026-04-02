import "package:flutter/material.dart";

import '../../core/resources/themes/app_colors.dart';
import '../../core/resources/themes/app_fonts.dart';

class SettingsForWidget extends StatelessWidget {
  const SettingsForWidget({
    required this.text,
    super.key,
    required this.controller,
    this.hintText,
  });
  final String text;
  final TextEditingController controller;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    double containerWidth = screenWidth > 600 ? 146 : 140;
    double containerHeight = 62;
    if (screenWidth <= 1334) {
      containerWidth = screenWidth > 600 ? 140 : 100;
      containerHeight = 48;
    } else if (screenWidth > 2732 && mediaQuery.size.height > 2048) {
      containerWidth = screenWidth > 600 ? 300 : 180;
      containerHeight = 80;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textAlign: TextAlign.left,
          text,
          style: AppFonts.w700s18.copyWith(
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: containerHeight,
          width: containerWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.white,
            border: Border.all(
              color: AppColors.grey,
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              hintText: hintText ?? "_",
            ),
          ),
        ),
      ],
    );
  }
}
