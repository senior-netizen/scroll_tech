// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variant_dto.dart';

VariantDto _$VariantDtoFromJson(Map<String, dynamic> json) => VariantDto(
      id: json['id'] as String,
      modelId: json['model_id'] as String,
      ram: json['ram'] as String,
      storage: json['storage'] as String,
      condition: json['condition'] as String,
      price: (json['price'] as num).toDouble(),
      stockStatus: json['stock_status'] as String,
    );

Map<String, dynamic> _$VariantDtoToJson(VariantDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'model_id': instance.modelId,
      'ram': instance.ram,
      'storage': instance.storage,
      'condition': instance.condition,
      'price': instance.price,
      'stock_status': instance.stockStatus,
    };
