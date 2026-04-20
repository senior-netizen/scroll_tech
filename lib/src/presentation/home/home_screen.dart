import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/dependencies.dart';
import '../../domain/models/models.dart';
import '../checkout/checkout_screen.dart';
import '../common/lazy_network_image.dart';
import '../inquiry/inquiry_screen.dart';
import '../product_details/product_details_screen.dart';
import '../product_list/product_list_screen.dart';
import '../shop_info/shop_info_screen.dart';
import '../tracking/tracking_screen.dart';

class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

class HomeState extends Equatable {
  const HomeState({
    this.loading = false,
    this.error,
    this.brands = const [],
    this.featured = const [],
    this.deal,
  });

  final bool loading;
  final String? error;
  final List<String> brands;
  final List<Product> featured;
  final Product? deal;

  HomeState copyWith({bool? loading, String? error, List<String>? brands, List<Product>? featured, Product? deal}) {
    return HomeState(
      loading: loading ?? this.loading,
      error: error,
      brands: brands ?? this.brands,
      featured: featured ?? this.featured,
      deal: deal ?? this.deal,
    );
  }

  @override
  List<Object?> get props => [loading, error, brands, featured, deal];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(HomeLoadRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final results = await Future.wait([
        AppDependencies.getBrandsUseCase(),
        AppDependencies.getFeaturedUseCase(),
        AppDependencies.getDealUseCase(),
      ]);
      emit(state.copyWith(
        loading: false,
        brands: results[0] as List<String>,
        featured: results[1] as List<Product>,
        deal: results[2] as Product,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'Failed to load home data'));
    }
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(const HomeLoadRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Scroll Tech Home')),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.loading && state.featured.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: [
                if (state.error != null)
                  ListTile(title: Text(state.error!, style: const TextStyle(color: Colors.redAccent))),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Brands', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) => Chip(label: Text(state.brands[i])),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: state.brands.length,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Deal of the Day', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                if (state.deal != null)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: ListTile(
                      leading: SizedBox(width: 56, child: LazyNetworkImage(url: state.deal!.imageUrl, height: 56)),
                      title: Text(state.deal!.name),
                      subtitle: Text('\$${state.deal!.price.toStringAsFixed(2)}'),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Featured', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...state.featured.map(
                  (product) => ListTile(
                    leading: SizedBox(width: 64, child: LazyNetworkImage(url: product.imageUrl, height: 64)),
                    title: Text(product.name),
                    subtitle: Text(product.brand),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => ProductDetailsScreen(productId: product.id)),
                    ),
                  ),
                ),
                const Divider(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _NavButton(label: 'Product List', destination: const ProductListScreen()),
                    _NavButton(label: 'Checkout', destination: const CheckoutScreen()),
                    _NavButton(label: 'Inquiry', destination: const InquiryScreen(contextText: 'General inquiry from home')),
                    _NavButton(label: 'Shop Info', destination: const ShopInfoScreen()),
                    _NavButton(label: 'Track Order', destination: const TrackingScreen()),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.destination});

  final String label;
  final Widget destination;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => destination)),
        child: Text(label),
      ),
    );
  }
}
