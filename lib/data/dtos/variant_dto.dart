import 'package:json_annotation/json_annotation.dart';

part 'variant_dto.g.dart';

@JsonSerializable()
class VariantDto {
  const VariantDto({
    required this.id,
    @JsonKey(name: 'model_id') required this.modelId,
    required this.ram,
    required this.storage,
    required this.condition,
    required this.price,
    @JsonKey(name: 'stock_status') required this.stockStatus,
  });

  final String id;
  final String modelId;
  final String ram;
  final String storage;
  final String condition;
  final double price;
  final String stockStatus;

  factory VariantDto.fromJson(Map<String, dynamic> json) =>
      _$VariantDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VariantDtoToJson(this);
}
