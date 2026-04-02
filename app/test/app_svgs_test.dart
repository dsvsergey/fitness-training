import 'dart:io';

import 'package:fitness_training/core/resources/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app_svgs assets test', () {
    expect(File(AppSvgs.calendar).existsSync(), isTrue);
    expect(File(AppSvgs.contacts).existsSync(), isTrue);
    expect(File(AppSvgs.metronom).existsSync(), isTrue);
    expect(File(AppSvgs.settings).existsSync(), isTrue);
    expect(File(AppSvgs.settingsProgram).existsSync(), isTrue);
    expect(File(AppSvgs.timer).existsSync(), isTrue);
  });
}
