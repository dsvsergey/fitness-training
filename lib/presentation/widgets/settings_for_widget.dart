import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;

    double containerWidth;
    if (screenWidth > 2732) {
      containerWidth = screenWidth > 600 ? 300 : 180;
    } else {
      containerWidth = screenWidth > 600 ? 140 : 100;
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
        SizedBox(
          width: containerWidth,
          child: FTextField(
            control: FTextFieldControl.managed(controller: controller),
            hint: hintText ?? '_',
          ),
        ),
      ],
    );
  }
}
