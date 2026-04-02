import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'location_model.g.dart';

abstract class LocationModel
    implements Built<LocationModel, LocationModelBuilder> {
  @BuiltValueField(wireName: 'AdditionalImageURLs')
  BuiltList<String>? get additionalImageURLs;

  @BuiltValueField(wireName: 'Address')
  String? get address;

  @BuiltValueField(wireName: 'Address2')
  String? get address2;

  @BuiltValueField(wireName: 'City')
  String? get city;

  @BuiltValueField(wireName: 'Latitude')
  double? get latitude;

  @BuiltValueField(wireName: 'Longitude')
  double? get longitude;

  @BuiltValueField(wireName: 'Name')
  String? get name;

  @BuiltValueField(wireName: 'Phone')
  String? get phone;

  @BuiltValueField(wireName: 'PhoneExtension')
  String? get phoneExtension;

  @BuiltValueField(wireName: 'PostalCode')
  String? get postalCode;

  @BuiltValueField(wireName: 'StateProvCode')
  String? get stateProvCode;

  @BuiltValueField(wireName: 'Amenities')
  BuiltList<AmenitiesModel>? get amenities;

  @BuiltValueField(wireName: 'BusinessDescription')
  String? get businessDescription;

  @BuiltValueField(wireName: 'Description')
  String? get description;

  @BuiltValueField(wireName: 'HasClasses')
  bool? get hasClasses;

  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'SiteID')
  int? get siteID;

  @BuiltValueField(wireName: 'Tax1')
  double? get tax1;

  @BuiltValueField(wireName: 'Tax2')
  double? get tax2;

  @BuiltValueField(wireName: 'Tax3')
  double? get tax3;

  @BuiltValueField(wireName: 'Tax4')
  double? get tax4;

  @BuiltValueField(wireName: 'Tax5')
  double? get tax5;

  @BuiltValueField(wireName: 'TotalNumberOfRatings')
  int? get totalNumberOfRatings;

  @BuiltValueField(wireName: 'AverageRating')
  double? get averageRating;

  @BuiltValueField(wireName: 'TotalNumberOfDeals')
  int? get totalNumberOfDeals;

  LocationModel._();
  factory LocationModel([void Function(LocationModelBuilder) updates]) =
      _$LocationModel;

  static Serializer<LocationModel> get serializer => _$locationModelSerializer;

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(LocationModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(LocationModel.serializer, this)
        as Map<String, dynamic>;
  }
}
