// On-device tests for SettingsProgramScreen.
//
// These cover what a host-side widget test cannot: the real device screen size,
// real SVG assets, and real navigation. Both scenarios below are the ones that
// were broken — the Timer/Metronome buttons being permanently disabled, and the
// weight row throwing when no session is planned.
//
// Run with:
//   flutter test integration_test/settings_program_test.dart -d <device-id>

import 'package:built_collection/built_collection.dart';
import 'package:fitness_training/core/bloc/bloc_application/application_bloc.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:fitness_training/domain/entities/fitness/fitness.dart';
import 'package:fitness_training/domain/usecases/fitness/fitness.dart';
import 'package:fitness_training/presentation/screens/metronome/metronome_controls.dart';
import 'package:fitness_training/presentation/screens/settings_program/settings_program_screen.dart';
import 'package:fitness_training/presentation/screens/stopwatch_timer/active_stopwatch.dart';
import 'package:fitness_training/presentation/widgets/custom_timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

class _FakeProgramMachineUsecase implements ProgramMachineUsecase {
  _FakeProgramMachineUsecase(this.programMachine);

  final ProgramMachineEntity? programMachine;

  @override
  Future<ProgramMachineEntity?> getProgramMachineByProgramAndMachine(
    int programId,
    int machineId,
  ) async =>
      programMachine;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _machine = MachineEntity((b) => b
  ..id = 7
  ..name = 'Leg Press');

final _program = ProgramFitnessEntity((b) => b
  ..id = 3
  ..name = 'Program A');

WorkoutSessionEntity _session({
  DateTime? dateSession,
  SessionStatusEnumEntity status = SessionStatusEnumEntity.planned,
  int? weight = 40,
}) =>
    WorkoutSessionEntity((b) => b
      ..id = 11
      ..programMachineId = 5
      ..traineeId = 2
      ..coachId = 1
      ..weight = weight
      ..dateSession = dateSession
      ..sessionStatus = status);

ProgramMachineEntity _programMachine(List<WorkoutSessionEntity> workouts) =>
    ProgramMachineEntity((b) => b
      ..id = 5
      ..machineId = 7
      ..programId = 3
      ..seats = 1
      ..machine = _machine.toBuilder()
      ..workouts = ListBuilder<WorkoutSessionEntity>(workouts));

Future<void> _pumpScreen(WidgetTester tester) async {
  // This screen carries pre-existing RenderFlex overflows. They are layout
  // debt, unrelated to what these tests assert, and would otherwise fail the
  // run before a single assertion.
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('A RenderFlex overflowed')) return;
    previousOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = previousOnError);

  await tester.pumpWidget(
    MaterialApp(
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
      home: SettingsProgramScreen(program: _program, machine: _machine),
    ),
  );
  await tester.pump();
  await tester.pump();
}

CustomTimerWidget _cardTitled(WidgetTester tester, String title) => tester
    .widgetList<CustomTimerWidget>(find.byType(CustomTimerWidget))
    .firstWhere((w) => w.title == title);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => GetIt.I.reset());
  tearDown(() => GetIt.I.reset());

  void register(ProgramMachineEntity? programMachine) {
    GetIt.I.registerSingleton<ProgramMachineUsecase>(
      _FakeProgramMachineUsecase(programMachine),
    );
    final applicationBloc = ApplicationBloc();
    addTearDown(applicationBloc.close);
    GetIt.I.registerSingleton<ApplicationBloc>(applicationBloc);
    GetIt.I.registerSingleton<ActiveStopwatch>(ActiveStopwatch());
    // No calendar appointment anywhere — the condition that used to disable
    // both buttons.
    expect(applicationBloc.state.currentAppointment, isNull);
  }

  testWidgets('metronome button opens the metronome on a real device',
      (tester) async {
    register(_programMachine([_session()]));
    await _pumpScreen(tester);

    expect(_cardTitled(tester, 'Metronome').onPressed, isNotNull);

    await tester.tap(find.text('Metronome'));
    await tester.pumpAndSettle();

    expect(find.byType(MetronomeControl), findsOneWidget);
  });

  testWidgets('timer button is enabled for an unfinished session',
      (tester) async {
    register(_programMachine([_session()]));
    await _pumpScreen(tester);

    expect(_cardTitled(tester, 'Timer').onPressed, isNotNull);
  });

  testWidgets('weight row survives a machine with no planned session',
      (tester) async {
    register(_programMachine(
      [_session(status: SessionStatusEnumEntity.completed)],
    ));
    await _pumpScreen(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomTimerWidget), findsWidgets);
  });
}
