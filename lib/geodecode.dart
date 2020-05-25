import 'package:json_annotation/json_annotation.dart';

part 'geodecode.g.dart';

@JsonSerializable()
class GeoDecodeResult {
  List<Result> results;

  GeoDecodeResult({ this.results });

  factory GeoDecodeResult.fromJson(Map<String, dynamic> json) => _$GeoDecodeResultFromJson(json);
  Map<String, dynamic> toJson() => _$GeoDecodeResultToJson(this);
}

@JsonSerializable()
class Result {
  Region region;

  Result({ this.region});

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);
  Map<String, dynamic> toJson() => _$ResultToJson(this);
}

@JsonSerializable()
class Region {
  Area1 area1;
  Area2 area2;

  Region({ this.area1, this.area2 });

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
  Map<String, dynamic> toJson() => _$RegionToJson(this);
}

@JsonSerializable()
class Area1 {
  String name;

  Area1({ this.name });

  factory Area1.fromJson(Map<String, dynamic> json) => _$Area1FromJson(json);
  Map<String, dynamic> toJson() => _$Area1ToJson(this);
}

@JsonSerializable()
class Area2 {
  String name;

  Area2({ this.name });

  factory Area2.fromJson(Map<String, dynamic> json) => _$Area2FromJson(json);
  Map<String, dynamic> toJson() => _$Area2ToJson(this);
}
