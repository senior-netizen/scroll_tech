import 'package:json_annotation/json_annotation.dart';

part 'order_dto.g.dart';

@JsonSerializable()
class OrderDto {
  const OrderDto({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'variant_id') required this.variantId,
    @JsonKey(name: 'deposit_amount') required this.depositAmount,
    required this.status,
  });

  final String id;
  final String userId;
  final String variantId;
  final double depositAmount;
  final String status;

  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDtoToJson(this);
}
