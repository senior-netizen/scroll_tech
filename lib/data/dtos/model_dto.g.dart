// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_dto.dart';

ModelDto _$ModelDtoFromJson(Map<String, dynamic> json) => ModelDto(
      id: json['id'] as String,
      brandId: json['brand_id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$ModelDtoToJson(ModelDto instance) => <String, dynamic>{
      'id': instance.id,
      'brand_id': instance.brandId,
      'name': instance.name,
    };
