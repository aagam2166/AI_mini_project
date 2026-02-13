import '../entities/history_item.dart';
import '../repositories/history_repo.dart';

class GetHistory {
  final HistoryRepo repo;
  GetHistory(this.repo);

  Future<List<HistoryItem>> call() => repo.get();
}
