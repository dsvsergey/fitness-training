import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class TextParametersUserWidget extends StatelessWidget {
  const TextParametersUserWidget({
    super.key,
    required this.textOne,
    required this.textTwo,
  });

  final String textOne;
  final String textTwo;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            textOne,
            textAlign: TextAlign.center,
            style: context.theme.typography.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            textTwo,
            textAlign: TextAlign.center,
            style: context.theme.typography.sm,
          ),
        ],
      );
}
