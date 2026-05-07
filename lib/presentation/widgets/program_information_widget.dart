import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ProgramInformationWidget extends StatelessWidget {
  const ProgramInformationWidget({
    super.key,
    required this.image,
    required this.text,
    required this.textInt,
  });

  final String image;
  final String text;
  final String textInt;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return Column(
      children: [
        Image.asset(
          image,
          height: (screenWidth > 600) ? 100 : 50,
          width: (screenWidth > 600) ? 100 : 50,
          color: context.theme.colors.foreground,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: context.theme.colors.mutedForeground,
                fontSize: (screenWidth > 600) ? 44 : 24,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              textInt,
              style: TextStyle(
                color: context.theme.colors.foreground,
                fontSize: (screenWidth > 600) ? 64 : 34,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
          ],
        )
      ],
    );
  }
}
