import 'package:fitness_training/presentation/utils/string_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats 10-digit numbers', () {
    expect('4378816478'.formatPhone(), '(437) 881-6478');
    expect('437-881-6478'.formatPhone(), '(437) 881-6478');
    expect('437.881.6478'.formatPhone(), '(437) 881-6478');
    expect(' (437) 881 6478 '.formatPhone(), '(437) 881-6478');
  });

  test('drops leading country code 1', () {
    expect('+1 437 881 6478'.formatPhone(), '(437) 881-6478');
    expect('14378816478'.formatPhone(), '(437) 881-6478');
  });

  test('leaves non-NANP numbers untouched', () {
    expect('+380632625621'.formatPhone(), '+380632625621');
    expect(' 12345 '.formatPhone(), '12345');
  });
}
