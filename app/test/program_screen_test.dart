// Tests for the client comment on the trainee profile (ProgramScreen).

import 'dart:io';
import 'dart:ui' as ui;

import 'package:built_collection/built_collection.dart';
import 'package:fitness_training/core/bloc/bloc_application/application_bloc.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:fitness_training/domain/entities/fitness/fitness.dart';
import 'package:fitness_training/presentation/screens/programs/program_screen/bloc/program_screen_bloc.dart';
import 'package:fitness_training/presentation/screens/programs/program_screen/program_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

final _boundaryKey = GlobalKey();

TraineeEntity _trainee({String? notes}) => TraineeEntity((b) => b
  ..id = 2
  ..firstName = 'Katherine'
  ..lastName = 'Miller'
  ..mobilePhone = '4165859253'
  ..notes = notes
  ..programs = ListBuilder<ProgramFitnessEntity>([
    ProgramFitnessEntity((p) => p
      ..id = 3
      ..name = 'Program A'
      ..isArchive = false
      ..createdAt = DateTime(2026, 9, 24)),
  ]));

Future<void> _pump(WidgetTester tester, TraineeEntity trainee) async {
  tester.view.physicalSize = const Size(1200, 1920);
  tester.view.devicePixelRatio = 1.5;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundaryKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => FTheme(
          data: FThemes.zinc.light.touch,
          child: child!,
        ),
        home: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ApplicationBloc()),
            BlocProvider(
              create: (_) =>
                  ProgramScreenBloc()..add(SetTraineeEvent(trainee: trainee)),
            ),
          ],
          child: const ProgramScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _screenshot(WidgetTester tester, String path) async {
  if (Platform.environment['SCREENSHOT_DIR'] == null) return;
  await tester.runAsync(() async {
    for (final f in ['packages/forui/Inter', 'Roboto']) {
      final loader = FontLoader(f);
      for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
        final file = File(
          '${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev/'
          'forui-0.20.4/assets/fonts/inter/Inter-$w.ttf',
        );
        if (file.existsSync()) {
          loader.addFont(Future.value(
            ByteData.view(file.readAsBytesSync().buffer),
          ));
        }
      }
      await loader.load();
    }
  });
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = _boundaryKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('${Platform.environment['SCREENSHOT_DIR']}/$path')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('profile shows the client comment', (tester) async {
    await _pump(tester, _trainee(notes: 'Bad left knee — no deep squats'));

    expect(find.text('Bad left knee — no deep squats'), findsOneWidget);
    await _screenshot(tester, 'profile_with_comment.png');
  });

  testWidgets('profile offers to add a comment when there is none',
      (tester) async {
    await _pump(tester, _trainee());

    expect(find.text('Add a comment about this client'), findsOneWidget);
    await _screenshot(tester, 'profile_empty.png');
  });
}
