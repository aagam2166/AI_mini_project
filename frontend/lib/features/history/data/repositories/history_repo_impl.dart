import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repo.dart';
import '../datasources/history_remote_ds.dart';

class HistoryRepoImpl implements HistoryRepo {
  final HistoryRemoteDs remote;
  HistoryRepoImpl(this.remote);

  @override
  Future<List<HistoryItem>> get() => remote.get();
}
