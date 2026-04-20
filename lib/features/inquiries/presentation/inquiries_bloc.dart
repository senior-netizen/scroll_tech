import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/inquiries_entity.dart';
import '../domain/get_inquiries_use_case.dart';

sealed class InquiriesState extends Equatable {
  const InquiriesState();

  @override
  List<Object?> get props => [];
}

class InquiriesInitial extends InquiriesState {
  const InquiriesInitial();
}

class InquiriesLoading extends InquiriesState {
  const InquiriesLoading();
}

class InquiriesLoaded extends InquiriesState {
  const InquiriesLoaded(this.items);

  final List<InquiriesEntity> items;

  @override
  List<Object?> get props => [items];
}

class InquiriesError extends InquiriesState {
  const InquiriesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class InquiriesCubit extends Cubit<InquiriesState> {
  InquiriesCubit(this._getInquiriesUseCase)
      : super(const InquiriesInitial());

  final GetInquiriesUseCase _getInquiriesUseCase;

  Future<void> load() async {
    emit(const InquiriesLoading());
    try {
      final items = await _getInquiriesUseCase.call();
      emit(InquiriesLoaded(items));
    } catch (_) {
      emit(const InquiriesError('Failed to load inquiries data'));
    }
  }
}
