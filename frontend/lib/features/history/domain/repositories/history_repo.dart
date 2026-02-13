import '../entities/history_item.dart';

abstract class HistoryRepo {
  Future<List<HistoryItem>> get();
}
