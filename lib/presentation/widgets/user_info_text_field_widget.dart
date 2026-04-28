import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            widget.text,
            style: isTablet
                ? context.theme.typography.lg
                    .copyWith(fontWeight: FontWeight.w700)
                : context.theme.typography.xs
                    .copyWith(fontWeight: FontWeight.w700),
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
