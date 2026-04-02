import 'package:flutter/material.dart';

class InvertedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double borderWidth = 20.0;

    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(borderWidth, borderWidth, size.width - 2 * borderWidth,
          size.height - 2 * borderWidth),
      const Radius.circular(0),
    ));

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
