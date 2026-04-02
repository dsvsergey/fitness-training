import 'package:flutter/material.dart';

class FixedWidthText extends StatelessWidget {
  final String data;
  final TextStyle style;
  final int width;

  const FixedWidthText({
    super.key,
    // required Key key,
    required this.data,
    required this.style,
    this.width = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: style.fontSize! * width,
      child: Text(
        data,
        style: style,
        textAlign: TextAlign.left,
      ),
    );
  }
}
