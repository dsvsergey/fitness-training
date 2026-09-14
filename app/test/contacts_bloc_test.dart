// Covers the local-only refresh of a contact in the list.
//
// The contact detail screen can change a trainee (avatar, profile fields) while
// ContactsBloc — which lives for the whole app — still holds the version it
// fetched. Without a way to hand the fresh entity back, the list shows a stale
// avatar until it happens to reload. UpdateTraineeContactEvent cannot serve:
// it PUTs the trainee back to the server, which would undo nothing but cost a
// pointless round trip and overwrite fields the detail screen never touched.

import 'package:built_collection/built_collection.dart';
import 'package:fitness_training/domain/entities/fitness/fitness.dart';
import 'package:fitness_training/domain/usecases/fitness/fitness.dart';
import 'package:fitness_training/presentation/screens/contacts/bloc/contacts_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

TraineeEntity _trainee(int id, {String? photoUrl}) => TraineeEntity(
      (b) => b
        ..id = id
        ..firstName = 'Ann'
        ..lastName = 'Lee'
        ..photoUrl = photoUrl,
    );

/// Serves the one list the seeding step needs; every other call would be a
/// network round trip this test is asserting does NOT happen.
class _StubTraineeUsecase implements TraineeUsecase {
  _StubTraineeUsecase(this.trainees);

  final List<TraineeEntity> trainees;
  int getTraineesCalls = 0;

  @override
  Future<TraineeOutEntity> getTrainees({
    int skip = 0,
    int limit = 100,
    String? q,
  }) async {
    getTraineesCalls++;
    return TraineeOutEntity(
      (b) => b
        ..totalCount = trainees.length
        ..trainees = ListBuilder(trainees),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected network call: ${invocation.memberName}');
}

void main() {
  late _StubTraineeUsecase usecase;

  setUp(() {
    usecase = _StubTraineeUsecase([_trainee(1), _trainee(2)]);
    GetIt.I.registerSingleton<TraineeUsecase>(usecase);
  });

  tearDown(() => GetIt.I.reset());

  /// Fills the bloc's state through the normal fetch path.
  Future<ContactsBloc> seededBloc() async {
    final bloc = ContactsBloc()..add(GetContactsList());
    await bloc.stream.firstWhere((s) => s is ContactsSuccess);
    return bloc;
  }

  test('replaces the matching trainee and leaves the others alone', () async {
    final bloc = await seededBloc();
    final updated = _trainee(2, photoUrl: 'https://example.com/a.png');

    bloc.add(ReplaceTraineeContactEvent(trainee: updated));
    final state = await bloc.stream.first;

    expect(state.clients!.map((c) => c.id), [1, 2]);
    expect(state.clients![0].photoUrl, isNull);
    expect(state.clients![1].photoUrl, 'https://example.com/a.png');
    await bloc.close();
  });

  test('does not call the API', () async {
    final bloc = await seededBloc();
    final callsAfterSeeding = usecase.getTraineesCalls;

    bloc.add(ReplaceTraineeContactEvent(
      trainee: _trainee(2, photoUrl: 'https://example.com/a.png'),
    ));
    await bloc.stream.first;

    expect(usecase.getTraineesCalls, callsAfterSeeding);
    await bloc.close();
  });

  test('ignores a trainee that is not in the list', () async {
    final bloc = await seededBloc();

    bloc.add(ReplaceTraineeContactEvent(
      trainee: _trainee(99, photoUrl: 'https://example.com/a.png'),
    ));
    // No new state to await: the rebuilt list equals the current one, and Bloc
    // drops a state equal to the one it already holds.
    await pumpEventQueue();

    expect(bloc.state.clients!.map((c) => c.id), [1, 2]);
    expect(bloc.state.clients!.every((c) => c.photoUrl == null), isTrue);
    await bloc.close();
  });
}
