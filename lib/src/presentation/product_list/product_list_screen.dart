import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/dependencies.dart';
import '../../domain/models/product.dart';
import '../common/lazy_network_image.dart';
import '../product_details/product_details_screen.dart';

class ProductListEvent extends Equatable {
  const ProductListEvent();
  @override
  List<Object?> get props => [];
}

class ProductListLoadRequested extends ProductListEvent {
  const ProductListLoadRequested({this.reset = false});
  final bool reset;
  @override
  List<Object?> get props => [reset];
}

class ProductListFilterChanged extends ProductListEvent {
  const ProductListFilterChanged({this.search = '', this.brand});
  final String search;
  final String? brand;
  @override
  List<Object?> get props => [search, brand];
}

class ProductListState extends Equatable {
  const ProductListState({
    this.products = const [],
    this.page = 1,
    this.loading = false,
    this.backgroundLoading = false,
    this.hasMore = true,
    this.search = '',
    this.brand,
    this.error,
  });

  final List<Product> products;
  final int page;
  final bool loading;
  final bool backgroundLoading;
  final bool hasMore;
  final String search;
  final String? brand;
  final String? error;

  ProductListState copyWith({
    List<Product>? products,
    int? page,
    bool? loading,
    bool? backgroundLoading,
    bool? hasMore,
    String? search,
    String? brand,
    String? error,
  }) {
    return ProductListState(
      products: products ?? this.products,
      page: page ?? this.page,
      loading: loading ?? this.loading,
      backgroundLoading: backgroundLoading ?? this.backgroundLoading,
      hasMore: hasMore ?? this.hasMore,
      search: search ?? this.search,
      brand: brand ?? this.brand,
      error: error,
    );
  }

  @override
  List<Object?> get props => [products, page, loading, backgroundLoading, hasMore, search, brand, error];
}

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  ProductListBloc() : super(const ProductListState()) {
    on<ProductListLoadRequested>(_load);
    on<ProductListFilterChanged>(_filter);
  }

  Future<void> _filter(ProductListFilterChanged event, Emitter<ProductListState> emit) async {
    emit(state.copyWith(search: event.search, brand: event.brand, page: 1, hasMore: true, products: []));
    add(const ProductListLoadRequested(reset: true));
  }

  Future<void> _load(ProductListLoadRequested event, Emitter<ProductListState> emit) async {
    if (state.loading || state.backgroundLoading || !state.hasMore) return;
    if (state.products.isEmpty || event.reset) {
      emit(state.copyWith(loading: true, error: null));
    } else {
      emit(state.copyWith(backgroundLoading: true, error: null));
    }
    try {
      final nextPage = event.reset ? 1 : state.page;
      final batch = await AppDependencies.getProductsUseCase(
        page: nextPage,
        pageSize: 8,
        search: state.search,
        brand: state.brand,
      );
      emit(state.copyWith(
        loading: false,
        backgroundLoading: false,
        products: [...(event.reset ? <Product>[] : state.products), ...batch],
        page: nextPage + 1,
        hasMore: batch.isNotEmpty,
      ));
    } catch (_) {
      emit(state.copyWith(loading: false, backgroundLoading: false, error: 'Unable to load products'));
    }
  }
}

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductListBloc()..add(const ProductListLoadRequested()),
      child: const _ProductListView(),
    );
  }
}

class _ProductListView extends StatefulWidget {
  const _ProductListView();

  @override
  State<_ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<_ProductListView> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 120) {
        context.read<ProductListBloc>().add(const ProductListLoadRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search products'),
                        onSubmitted: (v) => context.read<ProductListBloc>().add(ProductListFilterChanged(search: v, brand: state.brand)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String?>(
                      value: state.brand,
                      hint: const Text('Brand'),
                      items: const [null, 'Astra', 'Nimbus', 'Pixelon']
                          .map((b) => DropdownMenuItem<String?>(value: b, child: Text(b ?? 'All')))
                          .toList(),
                      onChanged: (v) => context.read<ProductListBloc>().add(ProductListFilterChanged(search: state.search, brand: v)),
                    ),
                  ],
                ),
              ),
              if (state.error != null) Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
              Expanded(
                child: state.loading && state.products.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        controller: _controller,
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: state.products.length,
                        itemBuilder: (_, i) {
                          final product = state.products[i];
                          return InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: (_) => ProductDetailsScreen(productId: product.id)),
                            ),
                            child: Card(
                              child: Column(
                                children: [
                                  Expanded(child: LazyNetworkImage(url: product.imageUrl, height: double.infinity)),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      children: [Text(product.name, maxLines: 1), Text('\$${product.price.toStringAsFixed(2)}')],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (state.backgroundLoading) const LinearProgressIndicator(minHeight: 2),
            ],
          );
        },
      ),
    );
  }
}
