import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repo.dart';
import '../datasources/dashboard_remote_ds.dart';

class DashboardRepoImpl implements DashboardRepo {
  final DashboardRemoteDs remote;
  DashboardRepoImpl(this.remote);

  @override
  Future<DashboardSummary> getSummary() => remote.getSummary();
}
