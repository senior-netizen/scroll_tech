import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/dependencies.dart';

class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => [];
}

class CheckoutSubmitted extends CheckoutEvent {
  const CheckoutSubmitted({required this.name, required this.phone, required this.paymentMethod, this.paymentProof});

  final String name;
  final String phone;
  final String paymentMethod;
  final String? paymentProof;

  @override
  List<Object?> get props => [name, phone, paymentMethod, paymentProof];
}

class CheckoutState extends Equatable {
  const CheckoutState({this.loading = false, this.orderId, this.error});

  final bool loading;
  final String? orderId;
  final String? error;

  CheckoutState copyWith({bool? loading, String? orderId, String? error}) {
    return CheckoutState(loading: loading ?? this.loading, orderId: orderId ?? this.orderId, error: error);
  }

  @override
  List<Object?> get props => [loading, orderId, error];
}

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(const CheckoutState()) {
    on<CheckoutSubmitted>(_submit);
  }

  Future<void> _submit(CheckoutSubmitted event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final orderId = await AppDependencies.submitOrderUseCase(
        name: event.name,
        phone: event.phone,
        paymentMethod: event.paymentMethod,
        paymentProofPath: event.paymentProof,
      );
      emit(state.copyWith(loading: false, orderId: orderId));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Order submission failed'));
    }
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _proof = TextEditingController();
  String _payment = 'Bank Transfer';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckoutBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Order Checkout')),
        body: BlocConsumer<CheckoutBloc, CheckoutState>(
          listener: (context, state) {
            if (state.orderId != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order created: ${state.orderId}')));
            }
          },
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _payment,
                  items: const ['Bank Transfer', 'Cash on Delivery', 'E-Wallet']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _payment = v ?? _payment),
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                ),
                TextField(controller: _proof, decoration: const InputDecoration(labelText: 'Payment Proof Path (optional)')),
                const SizedBox(height: 12),
                if (state.error != null) Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
                FilledButton(
                  onPressed: state.loading
                      ? null
                      : () => context.read<CheckoutBloc>().add(
                            CheckoutSubmitted(
                              name: _name.text,
                              phone: _phone.text,
                              paymentMethod: _payment,
                              paymentProof: _proof.text.isEmpty ? null : _proof.text,
                            ),
                          ),
                  child: state.loading ? const CircularProgressIndicator(strokeWidth: 2) : const Text('Place Order'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
