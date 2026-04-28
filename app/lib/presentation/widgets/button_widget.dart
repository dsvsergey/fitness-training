import 'package:forui/forui.dart';
import 'package:flutter/widgets.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    required this.onPressed,
    required this.title,
    super.key,
  });

  final VoidCallback? onPressed;
  final String title;

  @override
  Widget build(BuildContext context) => FButton(
        onPress: onPressed,
        child: Text(title),
      );
}
