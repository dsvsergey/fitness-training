import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'course_model.g.dart';

abstract class CourseModel implements Built<CourseModel, CourseModelBuilder> {
  @BuiltValueField(wireName: 'Id')
  int get id;

  @BuiltValueField(wireName: 'Name')
  String? get name;

  @BuiltValueField(wireName: 'Description')
  String? get description;

  @BuiltValueField(wireName: 'Notes')
  String? get notes;

  @BuiltValueField(wireName: 'StartDate')
  DateTime? get startDate;

  @BuiltValueField(wireName: 'EndDate')
  DateTime? get endDate;

  @BuiltValueField(wireName: 'Location')
  LocationModel? get location;

  @BuiltValueField(wireName: 'Organizer')
  StaffModel? get organizer;

  @BuiltValueField(wireName: 'Program')
  ProgramModel? get program;

  @BuiltValueField(wireName: 'ImageUrl')
  String? get imageUrl;

  CourseModel._();
  factory CourseModel([void Function(CourseModelBuilder) updates]) =
      _$CourseModel;

  static Serializer<CourseModel> get serializer => _$courseModelSerializer;

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(CourseModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(CourseModel.serializer, this)
        as Map<String, dynamic>;
  }
}
