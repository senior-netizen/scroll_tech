import 'package:json_annotation/json_annotation.dart';

part 'inquiry_dto.g.dart';

@JsonSerializable()
class InquiryDto {
  const InquiryDto({
    required this.id,
    @JsonKey(name: 'product_context') required this.productContext,
    required this.message,
    required this.status,
  });

  final String id;
  final String productContext;
  final String message;
  final String status;

  factory InquiryDto.fromJson(Map<String, dynamic> json) =>
      _$InquiryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryDtoToJson(this);
}
