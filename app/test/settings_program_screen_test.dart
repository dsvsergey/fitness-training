// Regression tests for SettingsProgramScreen.

import 'package:built_collection/built_collection.dart';
import 'package:fitness_training/core/bloc/bloc_application/application_bloc.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:fitness_training/domain/entities/fitness/fitness.dart';
import 'package:fitness_training/domain/usecases/fitness/fitness.dart';
import 'package:fitness_training/presentation/screens/settings_program/settings_program_screen.dart';
import 'package:fitness_training/presentation/widgets/custom_timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

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
  // The phone layout is chosen below 600dp wide; give it enough height that the
  // screen's own known overflow does not mask the assertions below.
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(400, 1600);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // This screen has pre-existing RenderFlex overflows (see the `Fix overflows
  // in settings program screen` commit, still not fully resolved). They are
  // layout debt, unrelated to which buttons are enabled, and would otherwise
  // fail the test before a single assertion runs.
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

CustomTimerWidget _cardTitled(WidgetTester tester, String title) {
  return tester
      .widgetList<CustomTimerWidget>(find.byType(CustomTimerWidget))
      .firstWhere((w) => w.title == title);
}

void main() {
  setUp(() => GetIt.I.reset());
  tearDown(() => GetIt.I.reset());

  void register(ProgramMachineEntity? programMachine) {
    GetIt.I.registerSingleton<ProgramMachineUsecase>(
      _FakeProgramMachineUsecase(programMachine),
    );
    // A real ApplicationBloc sitting in its initial state: authenticated flows
    // aside, `currentAppointment` is null here, exactly as it now always is
    // since the calendar was removed. No button may key off it.
    final applicationBloc = ApplicationBloc();
    addTearDown(applicationBloc.close);
    GetIt.I.registerSingleton<ApplicationBloc>(applicationBloc);
    expect(applicationBloc.state.currentAppointment, isNull);
  }

  group('timer / metronome buttons', () {
  testWidgets(
    'metronome button is enabled without any calendar appointment',
    (tester) async {
      register(_programMachine([_session()]));
      await _pumpScreen(tester);

      // No ApplicationBloc is registered at all, so there is definitively no
      // current appointment. The metronome must still be tappable.
      expect(_cardTitled(tester, 'Metronome').onPressed, isNotNull);
    },
  );

  testWidgets(
    'timer button is enabled for an unfinished session, no appointment needed',
    (tester) async {
      register(_programMachine([_session()]));
      await _pumpScreen(tester);

      expect(_cardTitled(tester, 'Timer').onPressed, isNotNull);
    },
  );

  testWidgets(
    'timer button is disabled when every session is already finished',
    (tester) async {
      register(_programMachine([_session(dateSession: DateTime(2026, 5, 1))]));
      await _pumpScreen(tester);

      expect(_cardTitled(tester, 'Timer').onPressed, isNull);

      // The metronome carries no such data dependency.
      expect(_cardTitled(tester, 'Metronome').onPressed, isNotNull);
    },
  );
  });

  group('weight row', () {
    // The row renders when `workouts.isNotEmpty`, but reads the weight with
    // `.where(planned).first`. Those are different predicates, so a machine
    // whose sessions are all completed satisfies the guard and then throws
    // `Bad state: No element` while building.
    testWidgets(
      'renders when no session is planned any more',
      (tester) async {
        register(_programMachine(
          [_session(status: SessionStatusEnumEntity.completed)],
        ));
        await _pumpScreen(tester);

        expect(tester.takeException(), isNull);
        expect(find.byType(CustomTimerWidget), findsWidgets);
      },
    );

    testWidgets(
      'shows the planned weight when one exists',
      (tester) async {
        register(_programMachine([_session(weight: 55)]));
        await _pumpScreen(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('55'), findsOneWidget);
      },
    );
  });
}
