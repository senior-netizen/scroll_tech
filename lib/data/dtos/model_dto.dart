import 'package:json_annotation/json_annotation.dart';

part 'model_dto.g.dart';

@JsonSerializable()
class ModelDto {
  const ModelDto({
    required this.id,
    @JsonKey(name: 'brand_id') required this.brandId,
    required this.name,
  });

  final String id;
  final String brandId;
  final String name;

  factory ModelDto.fromJson(Map<String, dynamic> json) =>
      _$ModelDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ModelDtoToJson(this);
}
