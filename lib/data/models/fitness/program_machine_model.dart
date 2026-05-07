import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fitness_training/data/models/fitness/fitness.dart';

import '../../../domain/entities/fitness/fitness.dart';
import '../models.dart';

part 'program_machine_model.g.dart';

abstract class ProgramMachineModel
    implements Built<ProgramMachineModel, ProgramMachineModelBuilder> {
  static Serializer<ProgramMachineModel> get serializer =>
      _$programMachineModelSerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'machine_id')
  int get machineId;

  @BuiltValueField(wireName: 'program_id')
  int get programId;

  @BuiltValueField(wireName: 'index')
  int? get index;

  MachineModel? get machine;

  int? get seats;

  int? get pin;

  int? get back;

  String? get handle;

  String? get knees;

  String? get legs;

  @BuiltValueField(wireName: 'for_two_legs')
  bool? get forTwoLegs;

  String? get chest;

  String? get angal;

  String? get note;

  String? get thighs;

  String? get grip;

  BuiltList<WorkoutSessionModel> get workouts;

  ProgramMachineModel._();

  factory ProgramMachineModel(
          [void Function(ProgramMachineModelBuilder) updates]) =
      _$ProgramMachineModel;

  static ProgramMachineModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        ProgramMachineModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(ProgramMachineModel.serializer, this)
        as Map<String, dynamic>;
  }
}

extension ProgramMachineModelExtension on ProgramMachineModel {
  ProgramMachineEntity get entity => ProgramMachineEntity((b) => b
    ..id = id
    ..machineId = machineId
    ..programId = programId
    ..index = index
    ..machine = machine?.entity.toBuilder()
    ..back = back
    ..handle = handle
    ..pin = pin
    ..seats = seats
    ..workouts = workouts.map((p0) => p0.entity).toBuiltList().toBuilder()
    ..angal = angal
    ..chest = chest
    ..forTwoLegs = forTwoLegs
    ..knees = knees
    ..legs = legs
    ..note = note
    ..thighs = thighs
    ..grip = grip);
}

extension ProgramMachineEntityExtension on ProgramMachineEntity {
  ProgramMachineModel get model => ProgramMachineModel((b) => b
    ..id = id
    ..machineId = machineId
    ..programId = programId
    ..index = index
    ..machine = machine?.model.toBuilder()
    ..back = back
    ..handle = handle
    ..pin = pin
    ..seats = seats
    ..workouts = workouts.map((p0) => p0.model).toBuiltList().toBuilder()
    ..angal = angal
    ..chest = chest
    ..forTwoLegs = forTwoLegs
    ..knees = knees
    ..legs = legs
    ..note = note
    ..thighs = thighs
    ..grip = grip);
}
