import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';

part 'level_model.g.dart';

abstract class LevelModel implements Built<LevelModel, LevelModelBuilder> {
  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'Name')
  String? get name;

  @BuiltValueField(wireName: 'Description')
  String? get description;

  LevelModel._();
  factory LevelModel([void Function(LevelModelBuilder) updates]) = _$LevelModel;

  static Serializer<LevelModel> get serializer => _$levelModelSerializer;

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(LevelModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(LevelModel.serializer, this)
        as Map<String, dynamic>;
  }
}
