import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app.dart';
import 'main.config.dart';

@InjectableInit()
void _configureDependencies() => GetIt.I.init();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  // await HiveRepository.initHive();
  _configureDependencies();
  runApp(const MyApp());
}
