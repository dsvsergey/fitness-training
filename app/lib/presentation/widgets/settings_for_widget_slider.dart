import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;

    double containerWidth;
    double containerHeight;
    if (screenWidth > 2732) {
      containerWidth = screenWidth > 600 ? 600 : 360;
      containerHeight = 80;
    } else {
      containerWidth = screenWidth > 600 ? 300 : 240;
      containerHeight = 48;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: context.theme.typography.lg
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Container(
          height: containerHeight,
          width: containerWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: context.theme.colors.background,
            border: Border.all(color: context.theme.colors.border),
          ),
          child: Row(
            children: [
              SizedBox(
                width: containerWidth / 2 - 1,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10),
                    hintText: hintText ?? '_',
                  ),
                ),
              ),
              SizedBox(
                width: containerWidth / 2 - 1,
                child: ValueListenableBuilder<int?>(
                  valueListenable: sliderValueNotifier,
                  builder: (context, value, _) =>
                      CupertinoSlidingSegmentedControl<int>(
                    children: {
                      0: SizedBox(
                        height: containerHeight - 7,
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.uni,
                            style: context.theme.typography.lg
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      1: Text(
                        AppLocalizations.of(context)!.bi,
                        style: context.theme.typography.lg
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    },
                    onValueChanged: (v) => sliderValueNotifier.value = v,
                    groupValue: value,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
