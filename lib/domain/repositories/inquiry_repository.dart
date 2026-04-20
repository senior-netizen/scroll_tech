import '../entities/inquiry.dart';

abstract class InquiryRepository {
  Future<Inquiry> submitInquiry(Inquiry inquiry);
}
