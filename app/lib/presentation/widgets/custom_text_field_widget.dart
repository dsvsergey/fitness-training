import 'package:flutter/material.dart';

class CustomTextFieldWidget extends StatelessWidget {
  const CustomTextFieldWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.hintText,
    this.keyboardType,
    this.errorText,
  });
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Widget? prefix;
  final Widget? suffix;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 600 ? 20 : 20,
      ),
      child: TextField(
        keyboardType: keyboardType,
        onChanged: onChanged,
        controller: controller,
        decoration: InputDecoration(
          errorText: errorText,
          contentPadding: const EdgeInsets.all(20.0),
          suffixIcon: suffix,
          prefix: prefix,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
