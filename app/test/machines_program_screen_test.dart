// Tests for the program comment on MachinesProgramScreen.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:built_collection/built_collection.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:fitness_training/domain/entities/fitness/fitness.dart';
import 'package:fitness_training/domain/usecases/fitness/fitness.dart';
import 'package:fitness_training/presentation/screens/machines_program/bloc/machines_program_screen_bloc.dart';
import 'package:fitness_training/presentation/screens/machines_program/machines_program_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

class _FakeProgramFitnessUsecase implements ProgramFitnessUsecase {
  _FakeProgramFitnessUsecase(this.program);

  ProgramFitnessEntity program;
  final updates = <ProgramFitnessEntity>[];

  @override
  Future<ProgramFitnessEntity> getProgram(int programId) async => program;

  @override
  Future<ProgramFitnessEntity> updateProgram(
    int programId,
    ProgramFitnessEntity program,
  ) async {
    updates.add(program);
    return this.program = program;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProgramMachineEntity _pm(int id, String name) => ProgramMachineEntity((b) => b
  ..id = id
  ..machineId = id
  ..programId = 3
  ..seats = 1
  ..machine = MachineEntity((m) => m
    ..id = id
    ..name = name).toBuilder()
  ..workouts = ListBuilder<WorkoutSessionEntity>());

ProgramFitnessEntity _program({String? comment}) =>
    ProgramFitnessEntity((b) => b
      ..id = 3
      ..name = 'Program A'
      ..comment = comment
      ..programMachines = ListBuilder<ProgramMachineEntity>([
        _pm(1, 'leg press'),
        _pm(2, 'chest press'),
        _pm(3, 'lat pulldown'),
      ]));

final _boundaryKey = GlobalKey();

Future<void> _pumpScreen(WidgetTester tester, {Size? size}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size ?? const Size(400, 900);
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
        home: BlocProvider(
          create: (_) => MachinesProgramScreenBloc(),
          child: MachinesProgramScreen(
            trainee: TraineeEntity((b) => b..id = 2),
            program: _program(),
          ),
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
  late _FakeProgramFitnessUsecase usecase;

  setUp(() => GetIt.I.reset());
  tearDown(() => GetIt.I.reset());

  void register(ProgramFitnessEntity program) {
    usecase = _FakeProgramFitnessUsecase(program);
    GetIt.I.registerSingleton<ProgramFitnessUsecase>(usecase);
  }

  testWidgets('shows saved comment above the machines', (tester) async {
    register(_program(comment: 'Knee pain — go light on leg press'));
    await _pumpScreen(tester);

    expect(find.text('Comment'), findsOneWidget);
    expect(find.text('Knee pain — go light on leg press'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Comment')).dy,
      lessThan(tester.getTopLeft(find.text('Leg Press')).dy),
    );
    await _screenshot(tester, 'with_comment.png');
  });

  testWidgets('saves a new comment to the program', (tester) async {
    register(_program());
    await _pumpScreen(tester);
    await _screenshot(tester, 'empty.png');

    await tester.enterText(find.byType(TextField), '  Warm up 10 min  ');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(usecase.updates, hasLength(1));
    expect(usecase.updates.single.comment, 'Warm up 10 min');
    expect(usecase.updates.single.name, 'Program A');
    expect(find.text('Save'), findsNothing);
    expect(find.text('Warm up 10 min'), findsOneWidget);
  });

  testWidgets('clearing the comment stores null', (tester) async {
    register(_program(comment: 'Old'));
    await _pumpScreen(tester);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(usecase.updates.single.comment, isNull);
  });
}
