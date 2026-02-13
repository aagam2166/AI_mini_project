import '../../domain/entities/analytics.dart';
import '../../domain/repositories/analytics_repo.dart';
import '../datasources/analytics_remote_ds.dart';

class AnalyticsRepoImpl implements AnalyticsRepo {
  final AnalyticsRemoteDs remote;
  AnalyticsRepoImpl(this.remote);

  @override
  Future<Analytics> get() => remote.get();
}
