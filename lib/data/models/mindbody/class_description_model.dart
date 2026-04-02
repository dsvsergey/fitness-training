import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fitness_training/data/models/mindbody/mindbody.dart';

import '../models.dart';

part 'class_description_model.g.dart';

abstract class ClassDescriptionModel
    implements Built<ClassDescriptionModel, ClassDescriptionModelBuilder> {
  @BuiltValueField(wireName: 'Active')
  bool? get active;

  @BuiltValueField(wireName: 'Description')
  String? get description;

  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'ImageURL')
  String? get imageURL;

  @BuiltValueField(wireName: 'LastUpdated')
  DateTime? get lastUpdated;

  @BuiltValueField(wireName: 'Level')
  LevelModel? get level;

  @BuiltValueField(wireName: 'Name')
  String? get name;

  @BuiltValueField(wireName: 'Notes')
  String? get notes;

  @BuiltValueField(wireName: 'Prereq')
  String? get prereq;

  @BuiltValueField(wireName: 'Program')
  ProgramModel? get program;

  @BuiltValueField(wireName: 'SessionType')
  SessionTypeEnum? get sessionType;

  @BuiltValueField(wireName: 'Category')
  String? get category;

  @BuiltValueField(wireName: 'CategoryId')
  int? get categoryId;

  @BuiltValueField(wireName: 'Subcategory')
  String? get subcategory;

  @BuiltValueField(wireName: 'SubcategoryId')
  int? get subcategoryId;

  ClassDescriptionModel._();
  factory ClassDescriptionModel(
          [void Function(ClassDescriptionModelBuilder) updates]) =
      _$ClassDescriptionModel;

  static Serializer<ClassDescriptionModel> get serializer =>
      _$classDescriptionModelSerializer;

  factory ClassDescriptionModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        ClassDescriptionModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(ClassDescriptionModel.serializer, this)
        as Map<String, dynamic>;
  }
}
