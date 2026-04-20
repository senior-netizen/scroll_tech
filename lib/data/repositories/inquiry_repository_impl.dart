import '../../domain/entities/inquiry.dart';
import '../../domain/repositories/inquiry_repository.dart';
import '../datasources/local/product_local_data_source.dart';
import '../datasources/remote/product_remote_data_source.dart';
import '../mappers/entity_dto_mappers.dart';

class InquiryRepositoryImpl implements InquiryRepository {
  InquiryRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
    required ProductLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;

  @override
  Future<Inquiry> submitInquiry(Inquiry inquiry) async {
    final responseDto = await _remoteDataSource.submitInquiry(inquiry.toDto());
    await _localDataSource.cacheSubmittedInquiry(responseDto);
    return responseDto.toEntity();
  }
}
