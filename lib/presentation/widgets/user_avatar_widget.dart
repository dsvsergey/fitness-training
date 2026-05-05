import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class UserAvatarWidget extends StatelessWidget {
  const UserAvatarWidget({
    super.key,
    required this.photoUrl,
    required this.initials,
    this.size = 40,
    this.textStyle,
  });

  final String? photoUrl;
  final String initials;
  final double size;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final fallback = Text(initials, style: textStyle);
    final url = photoUrl;
    if (url == null || url.isEmpty) {
      return FAvatar.raw(size: size, child: fallback);
    }
    return FAvatar(
      image: NetworkImage(url),
      fallback: fallback,
      size: size,
    );
  }
}
