import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/shop_entity.dart';
import '../domain/get_shop_use_case.dart';

sealed class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {
  const ShopInitial();
}

class ShopLoading extends ShopState {
  const ShopLoading();
}

class ShopLoaded extends ShopState {
  const ShopLoaded(this.items);

  final List<ShopEntity> items;

  @override
  List<Object?> get props => [items];
}

class ShopError extends ShopState {
  const ShopError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ShopCubit extends Cubit<ShopState> {
  ShopCubit(this._getShopUseCase)
      : super(const ShopInitial());

  final GetShopUseCase _getShopUseCase;

  Future<void> load() async {
    emit(const ShopLoading());
    try {
      final items = await _getShopUseCase.call();
      emit(ShopLoaded(items));
    } catch (_) {
      emit(const ShopError('Failed to load shop data'));
    }
  }
}
