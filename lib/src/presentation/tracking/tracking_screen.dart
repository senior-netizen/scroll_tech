import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/dependencies.dart';

class TrackingEvent extends Equatable {
  const TrackingEvent();
  @override
  List<Object?> get props => [];
}

class TrackingRequested extends TrackingEvent {
  const TrackingRequested(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

class TrackingState extends Equatable {
  const TrackingState({this.loading = false, this.status, this.error});
  final bool loading;
  final String? status;
  final String? error;

  TrackingState copyWith({bool? loading, String? status, String? error}) =>
      TrackingState(loading: loading ?? this.loading, status: status ?? this.status, error: error);

  @override
  List<Object?> get props => [loading, status, error];
}

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  TrackingBloc() : super(const TrackingState()) {
    on<TrackingRequested>(_track);
  }

  Future<void> _track(TrackingRequested event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final status = await AppDependencies.trackOrderUseCase(event.orderId);
      emit(state.copyWith(loading: false, status: status));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Tracking unavailable'));
    }
  }
}

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _order = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrackingBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Order Tracking')),
        body: BlocBuilder<TrackingBloc, TrackingState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(controller: _order, decoration: const InputDecoration(labelText: 'Order ID')),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: state.loading ? null : () => context.read<TrackingBloc>().add(TrackingRequested(_order.text)),
                    child: const Text('Track'),
                  ),
                  if (state.loading) const CircularProgressIndicator(),
                  if (state.status != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(state.status!)),
                  if (state.error != null) Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
