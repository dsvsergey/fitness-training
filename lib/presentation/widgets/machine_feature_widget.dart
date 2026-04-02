import 'package:flutter/material.dart';

class MachineFeatureWidget extends StatelessWidget {
  final String label;
  final String? value;
  final Widget icon;
  final String? additionalText;

  const MachineFeatureWidget({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    this.additionalText,
  });

  @override
  Widget build(BuildContext context) {
    return additionalText == null
        ? _withOutAdditionalText()
        : _withAdditionalText();
  }

  Column _withOutAdditionalText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        icon,
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 21.0,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                value ?? '',
                key: ValueKey<String>(value ?? ''),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 21.0,
                  color: Colors.black,
                ),
              ),
            ),
            if (additionalText != null)
              Text(
                additionalText!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 17.0,
                  color: Colors.grey,
                ),
              ),
          ],
        )
      ],
    );
  }

  Widget _withAdditionalText() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        width: 70,
        child: Stack(
          children: [
            icon,
            Positioned(
              right: 0,
              top: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  additionalText ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 17.0,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 24.0,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              value ?? '',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 24.0,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    ]);
  }
}
