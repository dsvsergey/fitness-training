import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/resources/themes/app_colors.dart';
import '../../core/resources/themes/app_fonts.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    required this.onPressed,
    required this.title,
    super.key,
  });
  final Function()? onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return SizedBox(
      width: screenWidth > 750 ? 230.w : double.infinity,
      height: screenWidth > 750 ? 60.h : 50.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorMain,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              30.r,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: screenWidth > 750 ? AppFonts.w700s25 : AppFonts.w700s18,
        ),
      ),
    );
  }
}
