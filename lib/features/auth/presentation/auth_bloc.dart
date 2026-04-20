import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/auth_entity.dart';
import '../domain/get_auth_use_case.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthLoaded extends AuthState {
  const AuthLoaded(this.items);

  final List<AuthEntity> items;

  @override
  List<Object?> get props => [items];
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._getAuthUseCase)
      : super(const AuthInitial());

  final GetAuthUseCase _getAuthUseCase;

  Future<void> load() async {
    emit(const AuthLoading());
    try {
      final items = await _getAuthUseCase.call();
      emit(AuthLoaded(items));
    } catch (_) {
      emit(const AuthError('Failed to load auth data'));
    }
  }
}
