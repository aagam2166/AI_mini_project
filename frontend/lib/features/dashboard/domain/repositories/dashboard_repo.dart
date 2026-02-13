import '../entities/dashboard_summary.dart';

abstract class DashboardRepo {
  Future<DashboardSummary> getSummary();
}
