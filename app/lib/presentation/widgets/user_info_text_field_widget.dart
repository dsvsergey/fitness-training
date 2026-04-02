import 'package:fitness_training/core/resources/themes/app_fonts.dart';
import 'package:flutter/material.dart';

import 'custom_text_field_widget.dart';

class UserInfoTextFieldWidget extends StatefulWidget {
  const UserInfoTextFieldWidget({
    super.key,
    required this.text,
    required this.hintText,
    this.onChanged,
    this.initialValue,
  });
  final String text;
  final String hintText;
  final Function(String)? onChanged;
  final String? initialValue;

  @override
  State<UserInfoTextFieldWidget> createState() =>
      _UserInfoTextFieldWidgetState();
}

class _UserInfoTextFieldWidgetState extends State<UserInfoTextFieldWidget> {
  late final TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: widget.initialValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            widget.text,
            style: screenWidth > 600 ? AppFonts.w700s19 : AppFonts.w700s13,
          ),
        ),
        const SizedBox(height: 10),
        CustomTextFieldWidget(
          controller: controller,
          hintText: widget.hintText,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
