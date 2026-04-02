import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'session_type_model.g.dart';

abstract class SessionTypeModel
    implements Built<SessionTypeModel, SessionTypeModelBuilder> {
  @BuiltValueField(wireName: 'Type')
  SessionTypeEnum? get type;

  @BuiltValueField(wireName: 'DefaultTimeLength')
  int? get defaultTimeLength;

  @BuiltValueField(wireName: 'StaffTimeLength')
  int? get staffTimeLength;

  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'Name')
  String? get name;

  @BuiltValueField(wireName: 'OnlineDescription')
  String? get onlineDescription;

  @BuiltValueField(wireName: 'NumDeducted')
  int? get numDeducted;

  @BuiltValueField(wireName: 'ProgramId')
  int? get programId;

  @BuiltValueField(wireName: 'Category')
  String? get category;

  @BuiltValueField(wireName: 'CategoryId')
  int? get categoryId;

  @BuiltValueField(wireName: 'Subcategory')
  String? get subcategory;

  @BuiltValueField(wireName: 'SubcategoryId')
  int? get subcategoryId;

  @BuiltValueField(wireName: 'AvailableForAddOn')
  bool? get availableForAddOn;

  SessionTypeModel._();
  factory SessionTypeModel([void Function(SessionTypeModelBuilder) updates]) =
      _$SessionTypeModel;

  static Serializer<SessionTypeModel> get serializer =>
      _$sessionTypeModelSerializer;

  factory SessionTypeModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(SessionTypeModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(SessionTypeModel.serializer, this)
        as Map<String, dynamic>;
  }
}
