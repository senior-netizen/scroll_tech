import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/notifications_entity.dart';
import '../domain/get_notifications_use_case.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded(this.items);

  final List<NotificationsEntity> items;

  @override
  List<Object?> get props => [items];
}

class NotificationsError extends NotificationsState {
  const NotificationsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._getNotificationsUseCase)
      : super(const NotificationsInitial());

  final GetNotificationsUseCase _getNotificationsUseCase;

  Future<void> load() async {
    emit(const NotificationsLoading());
    try {
      final items = await _getNotificationsUseCase.call();
      emit(NotificationsLoaded(items));
    } catch (_) {
      emit(const NotificationsError('Failed to load notifications data'));
    }
  }
}
