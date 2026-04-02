import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import '../../core/resources/themes/app_colors.dart';
import '../../core/resources/themes/app_fonts.dart';

class SettingsForWidgetSlider extends StatelessWidget {
  const SettingsForWidgetSlider({
    required this.text,
    super.key,
    required this.controller,
    required this.sliderValueNotifier,
    this.hintText,
  });
  final String text;
  final TextEditingController controller;
  final String? hintText;
  final ValueNotifier<int?> sliderValueNotifier;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    double containerWidth = screenWidth > 600 ? 300 : 240;
    double containerHeight = 62;
    if (screenWidth <= 1334) {
      containerWidth = screenWidth > 600 ? 300 : 240;
      containerHeight = 48;
    } else if (screenWidth > 2732 && mediaQuery.size.height > 2048) {
      containerWidth = screenWidth > 600 ? 600 : 360;
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
        Row(
          children: [
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
              child: Row(
                children: [
                  SizedBox(
                    width: containerWidth / 2 - 1,
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
                  const SizedBox(),
                  SizedBox(
                    width: containerWidth / 2 - 1,
                    child: CupertinoSlidingSegmentedControl<int>(
                      children: {
                        0: SizedBox(
                            height: containerHeight - 7,
                            child: Center(
                              child: Text(AppLocalizations.of(context)!.uni,
                                  style: AppFonts.w700s18.copyWith(
                                    color: AppColors.black,
                                  )),
                            )),
                        1: Text(
                          AppLocalizations.of(context)!.bi,
                          style: AppFonts.w700s18.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      },
                      onValueChanged: (int? newValue) =>
                          sliderValueNotifier.value = newValue,
                      groupValue: sliderValueNotifier.value,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
