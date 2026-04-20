import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/products_entity.dart';
import '../domain/get_products_use_case.dart';

sealed class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductsState {
  const ProductsLoaded(this.items);

  final List<ProductsEntity> items;

  @override
  List<Object?> get props => [items];
}

class ProductsError extends ProductsState {
  const ProductsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._getProductsUseCase)
      : super(const ProductsInitial());

  final GetProductsUseCase _getProductsUseCase;

  Future<void> load() async {
    emit(const ProductsLoading());
    try {
      final items = await _getProductsUseCase.call();
      emit(ProductsLoaded(items));
    } catch (_) {
      emit(const ProductsError('Failed to load products data'));
    }
  }
}
