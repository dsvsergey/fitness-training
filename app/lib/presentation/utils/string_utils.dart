import 'package:intl/intl.dart';

extension StringX on String {
  String capitalizeFirstWord() {
    return toBeginningOfSentenceCase(this);
  }

  String capitalizeEachWord() {
    return split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return '';
    }).join(' ');
  }
}

extension PhoneFormatX on String {
  /// Formats North American numbers as `(437) 881-6478`.
  /// Accepts any punctuation and an optional leading `+1`/`1`;
  /// anything that isn't a 10-digit NANP number is returned trimmed as-is.
  String formatPhone() {
    var digits = replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11 && digits.startsWith('1')) {
      digits = digits.substring(1);
    }
    if (digits.length != 10) return trim();
    return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
  }
}
