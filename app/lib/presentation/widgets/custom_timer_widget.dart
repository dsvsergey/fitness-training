import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:forui/forui.dart';

class CustomTimerWidget extends StatelessWidget {
  const CustomTimerWidget({
    required this.onPressed,
    required this.title,
    required this.image,
    super.key,
  });
  final VoidCallback onPressed;
  final String title;
  final String image;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    final double containerWidth = isTablet ? 207 : 160;
    final double containerHeight = isTablet ? 194 : 150;
    final double svgHeight = isTablet ? 90 : 70;
    final double svgWidth = isTablet ? 80 : 60;
    final double fontSize = isTablet ? 30 : 19;

    return GestureDetector(
      onTap: onPressed,
      child: FCard(
        child: SizedBox(
          width: containerWidth,
          height: containerHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  image,
                  height: svgHeight,
                  width: svgWidth,
                  colorFilter: ColorFilter.mode(
                    context.theme.colors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.md.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: fontSize,
                      color: context.theme.colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
