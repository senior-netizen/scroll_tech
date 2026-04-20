import 'dart:math';

import '../domain/models/models.dart';
import '../domain/repositories/repositories.dart';

class FakeCatalogRepository implements CatalogRepository {
  final List<Product> _products = List.generate(
    30,
    (i) => Product(
      id: 'p$i',
      name: 'Device ${i + 1}',
      brand: ['Astra', 'Nimbus', 'Pixelon'][i % 3],
      price: 49.99 + i * 7,
      stock: max(1, 12 - i % 10),
      imageUrl: 'https://picsum.photos/seed/device$i/600/600',
      variants: const ['Black', 'Silver', 'Blue'],
    ),
  );

  @override
  Future<List<String>> getBrands() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return ['Astra', 'Nimbus', 'Pixelon'];
  }

  @override
  Future<Product> getDealOfTheDay() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _products.first;
  }

  @override
  Future<List<Product>> getFeatured() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _products.take(6).toList(growable: false);
  }

  @override
  Future<Product> getProduct(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return _products.firstWhere((p) => p.id == id);
  }

  @override
  Future<List<Product>> getProducts({required int page, required int pageSize, String? search, String? brand}) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    var result = _products.where((p) {
      final searchMatch = (search == null || search.isEmpty) || p.name.toLowerCase().contains(search.toLowerCase());
      final brandMatch = brand == null || brand.isEmpty || p.brand == brand;
      return searchMatch && brandMatch;
    }).toList();

    final start = (page - 1) * pageSize;
    if (start >= result.length) return <Product>[];
    final end = min(start + pageSize, result.length);
    return result.sublist(start, end);
  }
}

class FakeCheckoutRepository implements CheckoutRepository {
  @override
  Future<String> submitOrder({required String name, required String phone, required String paymentMethod, String? paymentProofPath}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return 'ORD-${DateTime.now().millisecondsSinceEpoch}';
  }
}

class FakeInquiryRepository implements InquiryRepository {
  @override
  Future<String> createWhatsappDeepLink({required String context, required String phone}) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final encoded = Uri.encodeComponent('Hello, I have an inquiry: $context');
    return 'https://wa.me/$phone?text=$encoded';
  }
}

class FakeShopRepository implements ShopRepository {
  @override
  Future<ShopInfo> getShopInfo() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const ShopInfo(
      name: 'Scroll Tech Downtown',
      address: '100 Market St, Springfield',
      hours: 'Mon-Sat 09:00-20:00, Sun 10:00-18:00',
      mapUrl: 'https://maps.google.com/?q=100+Market+St+Springfield',
      directionsUrl: 'https://maps.google.com/?daddr=100+Market+St+Springfield',
    );
  }
}

class FakeTrackingRepository implements TrackingRepository {
  @override
  Future<String> track(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return 'Order $orderId is in transit and expected in 2 days.';
  }
}
