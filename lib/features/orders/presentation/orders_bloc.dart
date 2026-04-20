import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/orders_entity.dart';
import '../domain/get_orders_use_case.dart';

sealed class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  const OrdersLoaded(this.items);

  final List<OrdersEntity> items;

  @override
  List<Object?> get props => [items];
}

class OrdersError extends OrdersState {
  const OrdersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._getOrdersUseCase)
      : super(const OrdersInitial());

  final GetOrdersUseCase _getOrdersUseCase;

  Future<void> load() async {
    emit(const OrdersLoading());
    try {
      final items = await _getOrdersUseCase.call();
      emit(OrdersLoaded(items));
    } catch (_) {
      emit(const OrdersError('Failed to load orders data'));
    }
  }
}
