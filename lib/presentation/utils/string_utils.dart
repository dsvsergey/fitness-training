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
