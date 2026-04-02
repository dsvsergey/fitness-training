import 'dart:io';

import 'package:fitness_training/core/resources/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app_pngs assets test', () {
    expect(File(AppPngs.back).existsSync(), isTrue);
    expect(File(AppPngs.calendar).existsSync(), isTrue);
    expect(File(AppPngs.contacts).existsSync(), isTrue);
    expect(File(AppPngs.loginPhoto).existsSync(), isTrue);
    expect(File(AppPngs.loginPhotoTable).existsSync(), isTrue);
    expect(File(AppPngs.logo).existsSync(), isTrue);
    expect(File(AppPngs.settings).existsSync(), isTrue);
    expect(File(AppPngs.user).existsSync(), isTrue);
    expect(File(AppPngs.userImage).existsSync(), isTrue);
  });
}
