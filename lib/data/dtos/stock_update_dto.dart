import 'package:json_annotation/json_annotation.dart';

part 'stock_update_dto.g.dart';

@JsonSerializable()
class StockUpdateDto {
  const StockUpdateDto({
    @JsonKey(name: 'variant_id') required this.variantId,
    @JsonKey(name: 'stock_status') required this.stockStatus,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  final String variantId;
  final String stockStatus;
  final DateTime updatedAt;

  factory StockUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$StockUpdateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StockUpdateDtoToJson(this);
}
