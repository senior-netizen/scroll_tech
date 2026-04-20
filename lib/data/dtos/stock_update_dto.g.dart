// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_update_dto.dart';

StockUpdateDto _$StockUpdateDtoFromJson(Map<String, dynamic> json) =>
    StockUpdateDto(
      variantId: json['variant_id'] as String,
      stockStatus: json['stock_status'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$StockUpdateDtoToJson(StockUpdateDto instance) =>
    <String, dynamic>{
      'variant_id': instance.variantId,
      'stock_status': instance.stockStatus,
      'updated_at': instance.updatedAt.toIso8601String(),
    };
