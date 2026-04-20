// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry_dto.dart';

InquiryDto _$InquiryDtoFromJson(Map<String, dynamic> json) => InquiryDto(
      id: json['id'] as String,
      productContext: json['product_context'] as String,
      message: json['message'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$InquiryDtoToJson(InquiryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_context': instance.productContext,
      'message': instance.message,
      'status': instance.status,
    };
