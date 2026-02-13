import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repo.dart';

class GetDashboard {
  final DashboardRepo repo;
  GetDashboard(this.repo);

  Future<DashboardSummary> call() => repo.getSummary();
}
