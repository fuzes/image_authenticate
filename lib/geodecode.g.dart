// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geodecode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoDecodeResult _$GeoDecodeResultFromJson(Map<String, dynamic> json) {
  return GeoDecodeResult(
    results: (json['results'] as List)
        ?.map((e) =>
            e == null ? null : Result.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$GeoDecodeResultToJson(GeoDecodeResult instance) =>
    <String, dynamic>{
      'results': instance.results,
    };

Result _$ResultFromJson(Map<String, dynamic> json) {
  return Result(
    region: json['region'] == null
        ? null
        : Region.fromJson(json['region'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
      'region': instance.region,
    };

Region _$RegionFromJson(Map<String, dynamic> json) {
  return Region(
    area1: json['area1'] == null
        ? null
        : Area1.fromJson(json['area1'] as Map<String, dynamic>),
    area2: json['area2'] == null
        ? null
        : Area2.fromJson(json['area2'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RegionToJson(Region instance) => <String, dynamic>{
      'area1': instance.area1,
      'area2': instance.area2,
    };

Area1 _$Area1FromJson(Map<String, dynamic> json) {
  return Area1(
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$Area1ToJson(Area1 instance) => <String, dynamic>{
      'name': instance.name,
    };

Area2 _$Area2FromJson(Map<String, dynamic> json) {
  return Area2(
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$Area2ToJson(Area2 instance) => <String, dynamic>{
      'name': instance.name,
    };
