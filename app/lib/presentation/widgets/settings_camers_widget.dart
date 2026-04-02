import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

class SettingsCamersWidget extends StatelessWidget {
  const SettingsCamersWidget({
    required this.image,
    required this.title,
    super.key,
    this.onPressed,
  });

  final String image;
  final String title;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          SvgPicture.asset(
            image,
            height: 22,
            width: 22,
          ),
          const SizedBox(width: 30),
          TextButton(
            onPressed: onPressed,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: "Inter",
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
