import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fitness_training/data/models/fitness/program_fitness_model.dart';
import 'package:fitness_training/data/models/fitness/trainee_model.dart';
import 'package:fitness_training/domain/entities/fitness/trainee_entity.dart';
import 'package:fitness_training/domain/entities/fitness/trainee_out_entity.dart';

import '../models.dart';

part 'trainee_out_model.g.dart';

abstract class TraineeOutModel
    implements Built<TraineeOutModel, TraineeOutModelBuilder> {
  static Serializer<TraineeOutModel> get serializer =>
      _$traineeOutModelSerializer;

  @BuiltValueField(wireName: 'total_count')
  int? get totalCount;

  BuiltList<TraineeModel>? get trainees;

  TraineeOutModel._();

  factory TraineeOutModel([void Function(TraineeOutModelBuilder) updates]) =
      _$TraineeOutModel;

  static TraineeOutModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(TraineeOutModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(TraineeOutModel.serializer, this)
        as Map<String, dynamic>;
  }
}

extension TraineeOutModelExtension on TraineeOutModel {
  TraineeOutEntity get entity => TraineeOutEntity(
    (b) => b
      ..totalCount = totalCount
      ..trainees = trainees
          ?.map((p0) {
            return TraineeEntity(
              (e) => e
                ..id = p0.id
                ..firstName = p0.firstName
                ..lastName = p0.lastName
                ..email = p0.email
                ..mobilePhone = p0.mobilePhone
                ..homePhone = p0.homePhone
                ..workPhone = p0.workPhone
                ..address1 = p0.address1
                ..address2 = p0.address2
                ..city = p0.city
                ..state = p0.state
                ..postalCode = p0.postalCode
                ..country = p0.country
                ..birthDate = p0.birthDate
                ..gender = p0.gender
                ..notes = p0.notes
                ..photoUrl = p0.photoUrl
                ..createdAt = p0.createdAt
                ..updatedAt = p0.updatedAt
                ..height = p0.height
                ..weight = p0.weight
                ..programs = p0.programs
                    ?.map((p) => p.entity)
                    .toBuiltList()
                    .toBuilder(),
            );
          })
          .toBuiltList()
          .toBuilder(),
  );
}

extension TraineeOutEntityExtension on TraineeOutEntity {
  TraineeOutModel get model => TraineeOutModel(
    (b) => b
      ..totalCount = totalCount
      ..trainees = trainees
          ?.map(
            (p0) => TraineeModel(
              (m) => m
                ..id = p0.id
                ..firstName = p0.firstName
                ..lastName = p0.lastName
                ..email = p0.email
                ..mobilePhone = p0.mobilePhone
                ..homePhone = p0.homePhone
                ..workPhone = p0.workPhone
                ..address1 = p0.address1
                ..address2 = p0.address2
                ..city = p0.city
                ..state = p0.state
                ..postalCode = p0.postalCode
                ..country = p0.country
                ..birthDate = p0.birthDate
                ..gender = p0.gender
                ..notes = p0.notes
                ..photoUrl = p0.photoUrl
                ..createdAt = p0.createdAt
                ..updatedAt = p0.updatedAt
                ..height = p0.height
                ..weight = p0.weight
                ..programs = p0.programs
                    ?.map((p) => p.model)
                    .toBuiltList()
                    .toBuilder(),
            ),
          )
          .toBuiltList()
          .toBuilder(),
  );
}
