// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_dto.dart';

OrderDto _$OrderDtoFromJson(Map<String, dynamic> json) => OrderDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      variantId: json['variant_id'] as String,
      depositAmount: (json['deposit_amount'] as num).toDouble(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$OrderDtoToJson(OrderDto instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'variant_id': instance.variantId,
      'deposit_amount': instance.depositAmount,
      'status': instance.status,
    };
