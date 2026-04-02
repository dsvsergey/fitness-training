import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fitness_training/data/models/mindbody/mindbody.dart';

import '../models.dart';

part 'locations_model.g.dart';

abstract class LocationsModel
    implements Built<LocationsModel, LocationsModelBuilder> {
  @BuiltValueField(wireName: 'PaginationResponse')
  PaginationModel? get paginationResponse;

  @BuiltValueField(wireName: 'Locations')
  BuiltList<LocationModel>? get locations;

  LocationsModel._();
  factory LocationsModel([void Function(LocationsModelBuilder) updates]) =
      _$LocationsModel;

  static Serializer<LocationsModel> get serializer =>
      _$locationsModelSerializer;

  factory LocationsModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(LocationsModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(LocationsModel.serializer, this)
        as Map<String, dynamic>;
  }
}
