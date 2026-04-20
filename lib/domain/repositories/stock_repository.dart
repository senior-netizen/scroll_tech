import '../entities/stock_update.dart';

abstract class StockRepository {
  Future<List<StockUpdate>> fetchStockUpdates({DateTime? since});
}
