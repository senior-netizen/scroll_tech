import 'package:equatable/equatable.dart';

enum AsyncStatus { initial, loading, success, error }

class AsyncViewState<T> extends Equatable {
  const AsyncViewState({
    this.status = AsyncStatus.initial,
    this.data,
    this.message,
    this.backgroundLoading = false,
  });

  final AsyncStatus status;
  final T? data;
  final String? message;
  final bool backgroundLoading;

  AsyncViewState<T> copyWith({
    AsyncStatus? status,
    T? data,
    String? message,
    bool? backgroundLoading,
  }) {
    return AsyncViewState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      message: message,
      backgroundLoading: backgroundLoading ?? this.backgroundLoading,
    );
  }

  @override
  List<Object?> get props => [status, data, message, backgroundLoading];
}
