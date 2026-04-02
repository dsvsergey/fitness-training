import 'package:flutter/material.dart';
import '../../core/resources/themes/app_fonts.dart';

class TextParametersUserWidget extends StatelessWidget {
  const TextParametersUserWidget({
    super.key,
    required this.textOne,
    required this.textTwo,
  });
  final String textOne;
  final String textTwo;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          textAlign: TextAlign.center,
          textOne,
          style: screenWidth > 600 ? AppFonts.w400s24 : AppFonts.w400s18,
        ),
        const SizedBox(width: 5),
        Text(
          textAlign: TextAlign.center,
          textTwo,
          style: screenWidth > 600
              ? AppFonts.w400s23
              : AppFonts.w400s18.copyWith(
                  color: Colors.black,
                ),
        ),
      ],
    );
  }
}
