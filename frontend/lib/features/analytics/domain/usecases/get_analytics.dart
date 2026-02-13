import '../entities/analytics.dart';
import '../repositories/analytics_repo.dart';

class GetAnalytics {
  final AnalyticsRepo repo;
  GetAnalytics(this.repo);

  Future<Analytics> call() => repo.get();
}
