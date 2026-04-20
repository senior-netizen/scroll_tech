import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/dependencies.dart';
import '../../domain/models/product.dart';
import '../checkout/checkout_screen.dart';
import '../common/lazy_network_image.dart';
import '../inquiry/inquiry_screen.dart';

class ProductDetailsEvent extends Equatable {
  const ProductDetailsEvent();
  @override
  List<Object?> get props => [];
}

class ProductDetailsLoadRequested extends ProductDetailsEvent {
  const ProductDetailsLoadRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class ProductVariantChanged extends ProductDetailsEvent {
  const ProductVariantChanged(this.variant);
  final String variant;
  @override
  List<Object?> get props => [variant];
}

class ProductDetailsState extends Equatable {
  const ProductDetailsState({this.loading = false, this.error, this.product, this.selectedVariant});

  final bool loading;
  final String? error;
  final Product? product;
  final String? selectedVariant;

  ProductDetailsState copyWith({bool? loading, String? error, Product? product, String? selectedVariant}) {
    return ProductDetailsState(
      loading: loading ?? this.loading,
      error: error,
      product: product ?? this.product,
      selectedVariant: selectedVariant ?? this.selectedVariant,
    );
  }

  @override
  List<Object?> get props => [loading, error, product, selectedVariant];
}

class ProductDetailsBloc extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  ProductDetailsBloc() : super(const ProductDetailsState()) {
    on<ProductDetailsLoadRequested>(_load);
    on<ProductVariantChanged>(_changeVariant);
  }

  Future<void> _load(ProductDetailsLoadRequested event, Emitter<ProductDetailsState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final product = await AppDependencies.getProductDetailsUseCase(event.id);
      emit(state.copyWith(loading: false, product: product, selectedVariant: product.variants.first));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Unable to load product detail'));
    }
  }

  void _changeVariant(ProductVariantChanged event, Emitter<ProductDetailsState> emit) {
    emit(state.copyWith(selectedVariant: event.variant));
  }
}

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductDetailsBloc()..add(ProductDetailsLoadRequested(productId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
          builder: (context, state) {
            if (state.loading && state.product == null) return const Center(child: CircularProgressIndicator());
            final product = state.product;
            if (product == null) return Center(child: Text(state.error ?? 'Not found'));
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: LazyNetworkImage(url: product.imageUrl, height: 220)),
                const SizedBox(height: 12),
                Text(product.name, style: Theme.of(context).textTheme.titleLarge),
                Text('\$${product.price.toStringAsFixed(2)}'),
                if (product.lowStock)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Low stock!', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: product.variants
                      .map((v) => ChoiceChip(
                            label: Text(v),
                            selected: v == state.selectedVariant,
                            onSelected: (_) => context.read<ProductDetailsBloc>().add(ProductVariantChanged(v)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CheckoutScreen())),
                  child: const Text('Buy Now'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => InquiryScreen(contextText: 'Product ${product.name} - ${state.selectedVariant}')),
                  ),
                  child: const Text('Ask via WhatsApp'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
